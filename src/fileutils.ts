import * as crypto from 'crypto';
import * as fs from 'node:fs';
import { join } from 'node:path';
import { relative } from 'path';

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

export function getDirectories(path: string, recursive = false) {
	return fs
		.readdirSync(path, { withFileTypes: true, recursive })
		.filter((dirent) => dirent.isDirectory())
		.map((dirent) => dirent.name);
}

export function getFiles(path: string, recursive = false) {
	return fs
		.readdirSync(path, { withFileTypes: true, recursive })
		.filter((dirent) => dirent.isDirectory() === false)
		.map((dirent) => relative(path, join(dirent.path, dirent.name)));
}
