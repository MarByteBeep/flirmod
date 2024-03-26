import CRC32 from 'crc-32';
import * as fs from 'node:fs';

export function ensureLocalDirectory(path: string) {
	try {
		fs.statSync(path);
	} catch (err) {
		fs.mkdirSync(path, { recursive: true });
	}
}

export function getCRC(path: string): number | undefined {
	if (fs.existsSync(path) === false) {
		return undefined;
	}
	const stat = fs.statSync(path);
	if (stat.size === 0) {
		return undefined;
	}
	const file: Buffer = fs.readFileSync(path);
	return CRC32.buf(file);
}
