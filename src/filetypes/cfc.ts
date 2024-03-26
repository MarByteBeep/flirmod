import { strict as assert } from 'assert';
import * as crypto from 'crypto';
import * as fs from 'fs';
import { AppSettings } from '../AppSettings';
import { RC4 } from '../crypto/RC4';

const ver1 = 0x04;
const ver2 = 0x04;
const signatureLength = 0x80;
const tailLength = 0x10;
const tailMarkerStart = Buffer.from('CFC\0');
const tailMarkerEnd = 0x00;

function getKey() {
	const hashTail = '\x2a\x00';
	const hash = crypto.createHash('sha1');
	hash.update(Buffer.from(AppSettings.Camera.Suid, 'hex').reverse());
	hash.update(hashTail);
	return hash.digest().subarray(0, 16);
}

function getPadding(length: number) {
	return Math.ceil(length / 16.0) * 16 - length;
}

function decryptBuffer(contents: Buffer): Buffer {
	const offset = contents.length - tailLength;

	// Verify constants in tail
	assert.deepEqual(contents.subarray(offset, offset + 4), tailMarkerStart, `tailmarker mismatch`);
	assert.equal(contents.readInt16LE(offset + 4), ver1, `ver1 mismatch`);
	assert.equal(contents.readInt16LE(offset + 6), signatureLength, `signatureLength mismatch`);
	assert.equal(contents.readInt16LE(offset + 12), ver2, `ver2 mismatch`);
	assert.equal(contents.readInt16LE(offset + 14), tailMarkerEnd, `tailMarkerEnd mismatch`);

	const cfgSize = contents.readInt32LE(offset + 8);

	const decrypted = RC4(contents.subarray(0, cfgSize), getKey());

	return decrypted;
}

function decrypt(filepath: string): Buffer {
	const contents = fs.readFileSync(filepath);
	return decryptBuffer(contents);
}

export function decryptToFile(filein: string, fileout: string) {
	const contents = decrypt(filein);
	fs.writeFileSync(fileout, contents);
}

function encryptBuffer(contents: Buffer): Buffer {
	const key = getKey();

	const encrypted = RC4(contents, key);

	const padding = getPadding(contents.length);
	const appendixSize = padding + signatureLength + tailLength;

	const appendix = Buffer.alloc(appendixSize, 0);
	const offset = padding + signatureLength;
	tailMarkerStart.copy(appendix, offset);

	appendix.writeInt16LE(ver1, offset + 4);
	appendix.writeInt16LE(signatureLength, offset + 6);
	appendix.writeInt16LE(ver2, offset + 12);
	appendix.writeInt16LE(tailMarkerEnd, offset + 14);

	appendix.writeInt32LE(contents.length, offset + 8);

	return Buffer.concat([encrypted, appendix]);
}

function encrypt(filepath: string): Buffer {
	const contents = fs.readFileSync(filepath, 'ascii');
	return encryptBuffer(Buffer.from(contents));
}

export function encryptToFile(filein: string, fileout: string) {
	const contents = encrypt(filein);
	fs.writeFileSync(fileout, contents);
}

export function verifyEncryption(filepath: string) {
	const contents = fs.readFileSync(filepath);
	const decryptedBuffer = decryptBuffer(contents);
	const encryptedBuffer = encryptBuffer(decryptedBuffer);

	// Now these should be identical except for the signature, which are all zeros
	// So replace the signature (+padding?) to zeroes in the original content

	{
		// FIXME: Code duplication
		const offset = contents.length - tailLength;
		const cfgSize = contents.readInt32LE(offset + 8);
		const padding = getPadding(cfgSize);
		for (let i = 0; i < padding + signatureLength; ++i) {
			contents[i + cfgSize] = 0;
		}
	}

	assert.deepEqual(encryptedBuffer, contents);
}

export function hasOriginalSignature(filepath: string) {
	const contents = fs.readFileSync(filepath);

	// If CFC has original signature, its signature bytes should be non-zero
	{
		const offset = contents.length - tailLength;
		const cfgSize = contents.readInt32LE(offset + 8);
		const padding = getPadding(cfgSize);
		for (let i = 0; i < padding + signatureLength; ++i) {
			if (contents[i + cfgSize] > 0) {
				return true;
			}
		}
	}

	return false;
}
