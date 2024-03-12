import { expect } from 'bun:test';
import * as crypto from 'crypto';
import * as fs from 'fs';

const hashTail = '2A00';
const ver1 = 0x04;
const ver2 = 0x04;
const signatureLength = 0x80;
const tailLength = 0x10;
const tailMarkerStart = Buffer.from([0x43, 0x46, 0x43, 0x00]); // 'CFC\0'
const tailMarkerEnd = 0x00;

function getKey(suid: string) {
	const hash = crypto.createHash('sha1');
	hash.update(Buffer.from(suid, 'hex').reverse());
	hash.update(Buffer.from(hashTail, 'hex'));
	return hash.digest().subarray(0, 16);
}

function RC4(data: Buffer, key: Buffer): Buffer {
	let x = 0;
	let box = Array.from({ length: 256 }, (_, i) => i);
	for (let i = 0; i < 256; i++) {
		x = (x + box[i] + key[i % key.length]) & 255;
		[box[i], box[x]] = [box[x], box[i]];
	}
	let out: number[] = [];
	let y = 0;
	x = 0;
	data.forEach((char) => {
		x = (x + 1) & 255;
		y = (y + box[x]) & 255;
		[box[x], box[y]] = [box[y], box[x]];
		out.push(char ^ box[(box[x] + box[y]) & 255]);
	});

	return Buffer.from(out);
}

function getPadding(length: number) {
	return Math.ceil(length / 16.0) * 16 - length;
}

function decryptBuffer(contents: Buffer, suid: string): Buffer {
	const offset = contents.length - tailLength;

	// Verify constants in tail
	expect(contents.subarray(offset, offset + 4)).toEqual(tailMarkerStart);
	expect(contents.readInt16LE(offset + 4)).toBe(ver1);
	expect(contents.readInt16LE(offset + 6)).toBe(signatureLength);
	expect(contents.readInt16LE(offset + 12)).toBe(ver2);
	expect(contents.readInt16LE(offset + 14)).toBe(tailMarkerEnd);

	const cfgSize = contents.readInt32LE(offset + 8);

	return RC4(contents.subarray(0, cfgSize), getKey(suid));
}

export function decrypt(filepath: string, suid: string): Buffer {
	const contents = fs.readFileSync(filepath);
	return decryptBuffer(contents, suid);
}

export function decryptToFile(filein: string, suid: string, fileout: string) {
	const contents = decrypt(filein, suid);
	fs.writeFileSync(fileout, contents);
}

function encryptBuffer(contents: Buffer, suid: string): Buffer {
	const key = getKey(suid);

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

export function encrypt(filepath: string, suid: string): Buffer {
	const contents = fs.readFileSync(filepath, 'ascii');
	return encryptBuffer(Buffer.from(contents), suid);
}

export function encryptToFile(filein: string, suid: string, fileout: string) {
	const contents = encrypt(filein, suid);
	fs.writeFileSync(fileout, contents);
}

export function verifyEncryption(filepath: string, suid: string) {
	const contents = fs.readFileSync(filepath);
	const decryptedBuffer = decryptBuffer(contents, suid);
	const encryptedBuffer = encryptBuffer(decryptedBuffer, suid);

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

	expect(encryptedBuffer).toEqual(contents);
}
