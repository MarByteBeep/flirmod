import { stat, mkdir } from 'node:fs/promises';

export async function ensureLocalDirectory(path: string) {
	try {
		await stat(path);
	} catch (err) {
		await mkdir(path, { recursive: true });
	}
}
