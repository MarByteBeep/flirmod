import { strict as assert } from 'assert';
import chalk from 'chalk';
import { extname, join } from 'node:path';
import { AppSettings, type Patch } from './AppSettings';
import * as cfc from './filetypes/cfc';
import * as cfg from './filetypes/cfg';
import * as rsc from './filetypes/rsc';
import { ensureLocalDirectory, getFiles } from './fileutils';
import { verifyBackup } from './firmware';
import * as ftp from './ftp';
import { sleep, spinner } from './utils';

type PatchedFile = {
	remote: string;
	local: string;
};

type Map = {
	[key: string]: string;
};

function addFilesToMap(path: string, map: Map) {
	getFiles(path, true).forEach((e) => {
		const file = e.toLowerCase();
		if (file !== 'conf.cfg' && file !== 'dependencies.json' && map[file] === undefined) {
			map[file] = join(path, file);
		}
	});
}

function determinePatchedFiles(patch: Patch): PatchedFile[] {
	const filesToAdd: Map = {};
	addFilesToMap(patch.path, filesToAdd);

	// Now add all dependencies to the filelist as well
	for (const dependency of patch.dependencies) {
		addFilesToMap(AppSettings.PatchesPath + dependency, filesToAdd);
	}
	return Object.entries(filesToAdd).map((e) => ({
		remote: e[0],
		local: e[1],
	}));
}

function validatePatchedFiles(files: PatchedFile[]) {
	for (const file of files) {
		const ext = extname(file.local);

		switch (ext) {
			case '.rsc':
				rsc.read(file.local);
				break;
			default:
				break;
		}
	}
}

function getPatch(id: string): Patch | undefined {
	for (const patch of AppSettings.Patches) {
		if (id === patch.name) {
			return patch;
		}
	}

	return undefined;
}

async function prepareConfig(cfgPath: string) {
	ensureLocalDirectory(AppSettings.TempPath);

	try {
		verifyBackup();
	} catch (e: any) {
		throw new Error(`change config failed: ${e.message}, please make a new backup`);
	}

	try {
		const config = cfg.read(cfgPath);
		const filein = AppSettings.TempPath + 'conf.cfg';
		const fileout = AppSettings.TempPath + 'conf.cfc';
		cfg.replaceSerial(config, '123456789', AppSettings.Camera.SerialId);
		cfg.write(config, filein);
		cfc.encryptToFile(filein, fileout);
		cfc.verifyEncryption(fileout);
		return fileout;
	} catch (e: any) {
		throw new Error(`change config failed: ${e.message}`);
	}
}

export async function applyPatch(patchId: string) {
	assert.ok(AppSettings.Camera.HasPatchedDll, 'camera has unpatched common_dll.dll');

	const patch = getPatch(patchId);
	if (!patch) {
		throw new Error(`no patch with id: ${patchId}`);
	}
	spinner.start(`preparing patch '${patchId}'`);
	await sleep(1000);

	const files = determinePatchedFiles(patch);
	validatePatchedFiles(files);

	// first upload the config file
	const cfcLocalPath = await prepareConfig(join(patch.path, 'conf.cfg'));

	files.unshift({
		local: cfcLocalPath,
		remote: AppSettings.CfcRemotePath,
	});

	spinner.start(`uploading patch '${patchId}': ${chalk.yellow('DO NOT TOUCH CAMERA!')}`);

	await sleep(3000);

	spinner.start(`uploading patch '${patchId}':`);

	// Now upload all files to the camera

	try {
		for (const file of files) {
			spinner.suffixText = chalk.green(file.remote);
			await ftp.uploadFile(file.local, file.remote);
		}
	} catch (e: any) {
		spinner.suffixText = '';
		spinner.fail(
			`uploading patch '${patchId}' failed, error: '${chalk.red(e.message)}'\n${chalk.yellow(
				'!!! Camera might be in undefined state. Do NOT reset camera and retry applying patch !!!'
			)}`
		);
		return false;
	}
	spinner.suffixText = '';
	spinner.succeed(`patch '${patchId}' applied successfully`);
	return true;
}
