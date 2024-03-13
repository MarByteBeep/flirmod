import { existsSync, readFileSync } from 'fs';
import { decryptToFile, encryptToFile, verifyEncryption } from './crypt';
import { ensureLocalDirectory } from './utils';

export type SUID = string;

// FIXME: Make name CamIds more descriptive
export type CamIDs = {
	serial: string;
	suid: SUID;
};

export async function modFiles(backupPath: string, moddedFilesPath: string, ids: CamIDs) {
	await ensureLocalDirectory(moddedFilesPath);

	console.info('checking existence of vital files');
	// Confirm vital files have been backed up
	const vitalFiles = [
		'FlashIFS/version.rsc',
		'FlashBFS/system/common_dll.dll',
		'FlashFS/system/calib.rsc',
		'FlashFS/system/appcore.d/config.d/conf.cfc',
	];

	for (const file of vitalFiles) {
		if (existsSync(backupPath + file) === false) {
			throw new Error(`missing vital file '${file}' in backup`);
		}
	}
	console.log('all vital files have been backed up');

	{
		const filein = backupPath + 'FlashFS/system/appcore.d/config.d/conf.cfc';
		verifyEncryption(filein, ids);

		decryptToFile(filein, ids, moddedFilesPath + '/conf.cfg');
	}
}

export function getSUID(filepath: string): SUID {
	const file = readFileSync(filepath, 'ascii');
	const regex = /^\.version\.SUID text "([0-9A-F]{16})"$/gm;

	// FIXME: this method to get the first capture group seems too convoluted
	const matches = [...file.matchAll(regex)];
	if (matches.length !== 1 || matches[0].length !== 2) {
		throw new Error('cannot find SUID');
	}
	if (matches[0][1].length !== 16) {
		throw new Error('incorrect SUID length');
	}
	return matches[0][1];
}
