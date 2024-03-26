import { strict as assert } from 'assert';
import chalk from 'chalk';
import { join } from 'node:path';
import * as cfg from './filetypes/cfg';
import { getDirectories, getHashFromFile } from './fileutils';
import { spinner } from './utils';

export type Patch = {
	name: string;
	crc: string;
	path: string;
};

export class AppSettings {
	// Flir login credentials
	static readonly Username = 'flir';
	static readonly Password = '3vlig';

	// Paths
	static readonly BackupPath = './backup/';
	static readonly PatchesPath = './data/patches/';
	static readonly TempPath = './.temp/';
	static readonly CommonDllLocalPath = './data/patches/common_dll_3.16.dll';
	static readonly CommonDllRemotePath = './FlashBFS/system/common_dll.dll';
	static readonly CfcRemotePath = './FlashFS/system/appcore.d/config.d/conf.cfc';

	static readonly OriginalCfgLocalPath = './data/original/conf.cfg';
	static readonly BasicPatchCfgLocalPath = './data/patches/basic/conf.cfg';

	// common_dll.dll hashes
	static readonly PatchedDllHash = 'c61f71946829476082d84a28350ce101efd865a609303bf9e2741218fa64bcbe';
	static readonly UnpatchedDllHash = '81509856a567c1dc4848263ac7d9c58cdf2baf026f3b9a603df646be47e84b02';

	// Will be set at runtime
	static readonly Camera = {
		IpAddress: '',
		Suid: '',
		SerialId: '',
		HasPatchedDll: false,
	};

	static readonly Patches: Patch[] = [];

	static init() {
		{
			// Check if hardcoded hash matches the hash of the dll in AppSettings.CommonDllLocalPath
			// If not, it's been modified and app should exit
			const hashPatchedDll = getHashFromFile(AppSettings.CommonDllLocalPath);
			assert.equal(AppSettings.PatchedDllHash, hashPatchedDll, `patched dll hash mismatch`);
		}

		AppSettings.Camera.SerialId = process.env.SERIAL_ID ?? '';

		assert.notEqual(AppSettings.Camera.SerialId, '', 'Missing SERIAL_ID in .env file');

		assert.equal(
			AppSettings.Camera.SerialId.length,
			9,
			`Incorrect SERIAL_ID in .env file, '${AppSettings.Camera.SerialId}' should be a string of 9 digits, ` +
				`but has length ${AppSettings.Camera.SerialId.length}`
		);

		const regex = /^\d{9}$/;
		assert.ok(
			regex.test(AppSettings.Camera.SerialId),
			`Incorrect SERIAL_ID in .env file, '${AppSettings.Camera.SerialId}' should only contain digits`
		);

		spinner.succeed('valid serial id');

		// Read the available patches
		const patches = getDirectories(AppSettings.PatchesPath);
		try {
			for (const patch of patches) {
				const path = join(AppSettings.PatchesPath, patch, 'conf.cfg');
				const config = cfg.read(path);
				const crc = cfg.calculateCRC(config);
				AppSettings.Patches.push({
					name: patch,
					crc: crc,
					path: path,
				});
			}
		} catch (e: any) {
			throw new Error(`failed to load patches, error: ${e.message}`);
		}

		console.info(chalk.green('\nAvailable patches:'));
		for (const patch of AppSettings.Patches) {
			console.log(`- ${patch.name}`);
		}
		console.log();
	}
}
