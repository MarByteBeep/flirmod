import { strict as assert } from 'assert';
import chalk from 'chalk';
import * as fs from 'node:fs';
import { join } from 'node:path';
import * as cfg from './filetypes/cfg';
import { getDirectories, getHashFromFile } from './fileutils';
import { spinner } from './utils';

export type Patch = {
	name: string;
	path: string;
	dependencies: string[];
};

export class AppSettings {
	// Flir login credentials
	static readonly Username = 'flir';
	static readonly Password = '3vlig';

	// Paths
	static readonly BackupPath = './backup/';
	static readonly PatchesPath = './data/patches/';
	static readonly OriginalFilesPath = './data/original/';
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

		function parseDependencies(path: string) {
			try {
				const json = fs.existsSync(path) ? JSON.parse(fs.readFileSync(path, 'utf-8')) : [];
				return json.map((e: string) => e.toLowerCase());
			} catch (_) {
				return [];
			}
		}

		// Read the available patches
		const patches = getDirectories(AppSettings.PatchesPath);

		try {
			for (const patch of patches) {
				const path = AppSettings.PatchesPath + patch;
				const configPath = join(AppSettings.PatchesPath, patch);
				const dependenciesPath = join(AppSettings.PatchesPath, patch, 'dependencies.json');

				// read (and validate) config
				cfg.read(join(path, 'conf.cfg'));

				AppSettings.Patches.push({
					name: patch.toLowerCase(),
					path: path,
					dependencies: parseDependencies(dependenciesPath),
				});
			}
		} catch (e: any) {
			throw new Error(`failed to load patches, error: ${e.message}`);
		}

		// Verify if dependencies exist
		const dependencies = AppSettings.Patches.map((e) => e.name);
		for (const patch of AppSettings.Patches) {
			patch.dependencies.forEach((e) => {
				assert(e !== patch.name, `patch '${patch.name}' depends on itself`);
				assert(dependencies.includes(e), `patch '${patch.name}' depends on missing patch: '${e}'`);
			});
		}

		console.info(chalk.green('\nAvailable patches:'));
		for (const patch of AppSettings.Patches) {
			if (patch.dependencies.length > 0) {
				console.log(`- ${patch.name} ` + chalk.green('[depends on: ' + patch.dependencies.join(', ') + ']'));
			} else {
				console.log(`- ${patch.name}`);
			}
		}
		console.log();
	}
}
