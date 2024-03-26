import { strict as assert } from 'assert';
import chalk from 'chalk';
import { existsSync, readFileSync } from 'fs';
import { AppSettings } from './AppSettings';
import * as cfc from './filetypes/cfc';
import * as cfg from './filetypes/cfg';
import { ensureLocalDirectory } from './fileutils';
import * as ftp from './ftp';
import type { SUID } from './types';
import { spinner } from './utils';

function verifyBackup() {
	const files = [
		'FlashIFS/version.rsc',
		'FlashBFS/system/common_dll.dll',
		'FlashFS/system/calib.rsc',
		'FlashFS/system/appcore.d/config.d/conf.cfc',
	];

	for (const file of files) {
		if (existsSync(AppSettings.BackupPath + file) === false) {
			throw new Error('missing essential file(s) in backup');
		}
	}

	// Verify
	const filein = AppSettings.BackupPath + 'FlashFS/system/appcore.d/config.d/conf.cfc';
	cfc.verifyEncryption(filein);
	if (cfc.hasOriginalSignature(filein) == false) {
		throw new Error(`conf.cfc in backup doesn't have an original signature`);
	}
}

export async function restoreOriginalConfig() {
	assert.ok(AppSettings.Camera.HasPatchedDll);

	await changeConfig(AppSettings.OriginalCfgLocalPath);
}

export async function applyBasicPatch() {
	assert.ok(AppSettings.Camera.HasPatchedDll);

	await changeConfig(AppSettings.BasicPatchCfgLocalPath);
}

export async function changeConfig(cfgPath: string) {
	ensureLocalDirectory(AppSettings.PatchedFilesPath);

	spinner.start(`change config to '${cfgPath}'`);

	try {
		verifyBackup();
	} catch (e: any) {
		spinner.fail(`change config failed: ${e.message}, ${chalk.red('please make a new backup')}`);
		return;
	}

	try {
		const config = cfg.read(cfgPath);
		const filein = AppSettings.PatchedFilesPath + 'conf.cfg';
		const fileout = AppSettings.PatchedFilesPath + 'conf.cfc';
		cfg.replaceSerial(config, '123456789', AppSettings.Camera.SerialId);
		cfg.write(config, filein);
		cfc.encryptToFile(filein, fileout);
		cfc.verifyEncryption(fileout);
		await ftp.uploadFile(fileout, AppSettings.CfcRemotePath);
	} catch (e: any) {
		spinner.fail(`change config failed: ${chalk.red(e.message)}`);
		return;
	}
	spinner.succeed(`change config successful`);
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
