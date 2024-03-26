import * as crypto from 'crypto';
import * as fs from 'node:fs';

export function ensureLocalDirectory(path: string) {
	try {
		fs.statSync(path);
	} catch (err) {
		fs.mkdirSync(path, { recursive: true });
	}
}

export function getHashFromBuffer(buffer: Buffer): string {
	const hash = crypto.createHash('sha256');
	hash.update(buffer);
	return hash.digest('hex');
}

export function getHashFromFile(path: string): string | undefined {
	if (fs.existsSync(path) === false) {
		return undefined;
	}
	const stat = fs.statSync(path);
	if (stat.size === 0) {
		return undefined;
	}
	const file: Buffer = fs.readFileSync(path);
	return getHashFromBuffer(file);
}

export function getDirectories(path: string) {
	return fs
		.readdirSync(path, { withFileTypes: true })
		.filter((dirent) => dirent.isDirectory())
		.map((dirent) => dirent.name);
}
