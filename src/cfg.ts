import * as fs from 'fs';
import { strict as assert } from 'assert';
import { CRMD160 } from './CRMD160';

type CFG = string[];

const delimiter = '\r\n';

function toBuffer(cfg: CFG): Buffer {
	return Buffer.from(cfg.join(delimiter) + delimiter);
}

function calculateCRC(cfg: CFG) {
	const hash = new CRMD160(3);
	const input = toBuffer(cfg);
	hash.update(input);
	const digest = Buffer.from(new Uint8Array(CRMD160.getDigestLength()));
	hash.digest(digest);
	const crc = digest.readUInt32LE(0);
	return crc.toString(16);
}

function validateIdLine(line: string) {
	const regex = /^# ID ([0-9]{9})$/;
	const readSerial = regex.exec(line)?.at(1);
	return readSerial !== undefined;
}

export function read(filepath: string): CFG {
	const contentsWithCRC = fs.readFileSync(filepath, 'ascii');

	// cfg files always end with:
	// # ID XXXXXXXXX\r\n
	// # CRC03 XXXXXXXX\r\n
	// \r\n
	// where X is a lowercase hexadecimal character
	const cfg = contentsWithCRC.split(delimiter);
	assert.equal(cfg.at(-1), '', `${filepath}: should end with a newline`);

	assert.ok(validateIdLine(cfg.at(-3) ?? ''), `${filepath}: last line should be like '# ID XXXXXXXXX'`);

	const regex = /^# CRC03 ([0-9a-f]{8})$/;
	const readCrc = regex.exec(cfg.at(-2) ?? '')?.at(1);
	assert.notEqual(readCrc, undefined, `${filepath}: last line should be like '# CRC03 XXXXXXXX'`);

	// Remove last two lines (CRC32 and newline)
	cfg.pop();
	cfg.pop();

	// CFG should be at least 50 lines
	assert(cfg.length >= 50, `invalid config length: ${cfg.length}`);

	const crc = calculateCRC(cfg);
	assert.equal(readCrc, crc, `${filepath}: has mismatching crcs, read: '${readCrc}' calculated: '${crc}'`);

	return cfg;
}

export function replaceSerial(cfg: CFG, oldSerial: string, newSerial: string) {
	if (cfg.length < 1) {
		// Just prevent array out of bounds
		return;
	}
	const idLine = cfg[cfg.length - 1];
	assert.ok(validateIdLine(idLine), `config id line should be like '# ID XXXXXXXXX'`);
	assert.equal(idLine, `# ID ${oldSerial}`, `failed to find serial '${oldSerial}' in config file`);

	cfg[cfg.length - 1] = `# ID ${newSerial}`;
	assert.ok(validateIdLine(cfg[cfg.length - 1]), `new serial should be like 'XXXXXXXXX'`);
}

export function write(cfg: CFG, filepath: string) {
	const crc = calculateCRC(cfg);
	cfg.push(`# CRC03 ${crc}`);
	fs.writeFileSync(filepath, toBuffer(cfg), 'ascii');
}
