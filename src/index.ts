import { strict as assert } from 'assert';
import chalk from 'chalk';
import { AppSettings } from './AppSettings';
import { applyBasicPatch, restoreOriginalConfig } from './firmware';
import * as ftp from './ftp';
import * as menu from './menu';
import { MainMenuOption } from './menu';
import { applyPatch } from './patch';
import * as telnet from './telnet';
import type { SUID } from './types';
import { getCameraIpAddress, restartCamera, spinner } from './utils';

async function exit(code: number) {
	await ftp.close();
	await telnet.close();
	process.exit(code);
}

console.info(chalk.bold(chalk.yellow('\nFlir E4 firmware patcher')));
console.info('Requirements:\n- Flir E4 WiFi\n- camera version: 2.0L\n- firmware version: 3.16.0\n');

try {
	AppSettings.init();

	const camIp = await getCameraIpAddress();
	if (!camIp) {
		await exit(1);
	}

	AppSettings.Camera.IpAddress = camIp!;

	let suid: SUID | undefined = undefined;

	// Connect FTP
	{
		const connected = await ftp.connect();
		if (!connected) {
			await exit(1);
		}

		suid = await ftp.getSUID();
	}

	// Connect Telnet
	{
		const connected = await telnet.connect();
		if (!connected) {
			await exit(1);
		}

		const telnetSuid = await telnet.getSUID();

		// Ensure the suids are identical
		assert.equal(suid, telnetSuid, `mismatch between retreived suids ftp/telnet: '${suid}/${telnetSuid}'`);
	}

	spinner.succeed(`suid: ${chalk.green(suid)}`);
	AppSettings.Camera.Suid = suid;

	// Check if camera contains patched dll
	if (true) {
		spinner.start('checking for patched dll');
		const hash = await ftp.getRemoteHash(AppSettings.CommonDllRemotePath);
		AppSettings.Camera.HasPatchedDll = hash === AppSettings.PatchedDllHash;

		if (AppSettings.Camera.HasPatchedDll) {
			spinner.succeed('camera contains patched dll');
		} else {
			if (hash === AppSettings.UnpatchedDllHash) {
				spinner.fail(`camera doesn't contain patched common_dll.dll, but camera can be patched`);
			} else {
				spinner.fail(
					`camera has incorrect common_dll.dll, firmware '3.16.0' required. Upgrade firmware and retry.`
				);
				await exit(1);
			}
		}
	}

	let done = false;
	while (true) {
		const option = await menu.main();

		switch (option) {
			case MainMenuOption.Backup:
				if (await menu.confirm()) {
					await ftp.downloadToDir(AppSettings.BackupPath, './');
				}
				break;

			case MainMenuOption.Basic:
				if (await applyPatch('basic')) {
					await restartCamera();
				}
				break;

			case MainMenuOption.Advanced:
				if (await applyPatch('advanced')) {
					await restartCamera();
				}
				break;

			case MainMenuOption.Christmas:
				if (await applyPatch('christmas')) {
					await restartCamera();
				}
				break;

			case MainMenuOption.Revert:
				await restoreOriginalConfig();
				await restartCamera();
				break;

			case MainMenuOption.Exit:
				done = true;
				break;

			case MainMenuOption.Restart:
				await restartCamera();
				break;

			default:
				break;
		}
		if (done) {
			console.log('exiting ...');
			break;
		}
	}
} catch (e: any) {
	console.error(chalk.red(`error: ${e.message ?? e}`));
	console.error(chalk.red(`exiting ...`));
	await exit(1);
}

await exit(0);
