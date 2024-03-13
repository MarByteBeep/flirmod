import { strict as assert } from 'assert';
import CRC32 from 'crc-32';
import * as fs from 'fs';

type RSC = string[];

function calculateCRC(rsc: RSC) {
	// crc32 is calculated with last character being a newline
	// furthermore, coerce crc to an unsigned integer by using >>> 0
	const crc = CRC32.str(rsc.join('\n') + '\n') >>> 0;
	return crc.toString(16).padStart(8, '0');
}

export function read(filepath: string): RSC {
	const contentsWithCRC = fs.readFileSync(filepath, 'ascii');

	// rsc files always end with:
	// # CRC32 XXXXXXXX\n
	// \n
	// where X is a lowercase hexadecimal character
	const rsc = contentsWithCRC.split('\n');
	assert.equal(rsc.at(-1), '', `${filepath}: should end with a newline`);

	const regex = /^# CRC32 ([0-9a-f]{8})\s$/;
	const readCrc = regex.exec(rsc.at(-2) ?? '')?.at(1);
	assert.notEqual(readCrc, undefined, `${filepath}: last line should be like '# CRC32 XXXXXXXX'`);

	// Remove last two lines (CRC32 and newline)
	rsc.pop();
	rsc.pop();

	const crc = calculateCRC(rsc);
	assert.equal(readCrc, crc, `${filepath}: has mismatching crcs, read: '${readCrc}' calculated: '${crc}'`);

	return rsc;
}

export function write(rsc: RSC, filepath: string) {
	const crc = calculateCRC(rsc);
	rsc.push(`# CRC32 ${crc}`);
	rsc.push('');
	fs.writeFileSync(filepath, rsc.join('\n'), 'ascii');
}
