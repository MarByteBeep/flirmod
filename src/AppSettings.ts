import { strict as assert } from 'assert';
import { getHashFromFile } from './fileutils';

export class AppSettings {
	// Flir login credentials
	static readonly Username = 'flir';
	static readonly Password = '3vlig';

	// Paths
	static readonly BackupPath = './backup/';
	static readonly PatchedFilesPath = './patched/';
	static readonly CommonDllLocalPath = './data/patches/common_dll_3.16.dll';
	static readonly CommonDllRemotePath = './FlashBFS/system/common_dll.dll';
	static readonly CfcRemotePath = './FlashFS/system/appcore.d/config.d/conf.cfc';

	static readonly OriginalCfgLocalPath = './data/original/conf.cfg';
	static readonly BasicPatchCfgLocalPath = './data/patches/basic/conf.cfg';

	// Common hashes
	static readonly PatchedDllHash = 'c61f71946829476082d84a28350ce101efd865a609303bf9e2741218fa64bcbe';

	// Will be set at runtime
	static readonly Camera = {
		IpAddress: '',
		Suid: '',
		SerialId: '',
		HasPatchedDll: false,
	};

	static init() {
		const crcPatchedDll = getHashFromFile(AppSettings.CommonDllLocalPath);
		assert.equal(AppSettings.PatchedDllHash, crcPatchedDll, `patched dll hash mismatch`);

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
	}
}
