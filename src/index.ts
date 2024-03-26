import { strict as assert } from 'assert';
import chalk from 'chalk';
import { getHashFromFile } from './fileutils';
import * as ftp from './ftp';
import { setLoginCredentials } from './logincredentials';
import * as menu from './menu';
import { MainMenuOption } from './menu';
import * as telnet from './telnet';
import type { SUID } from './types';
import { getCameraIpAddress, initIds, restartCamera, spinner } from './utils';

const username = 'flir';
const password = '3vlig';

const backupPath = './backup/';
const moddedFilesPath = './modded/';

const crcModdedDll = getHashFromFile('./data/common_dll_3.16.dll');

async function exit(code: number) {
	await ftp.close();
	await telnet.close();
	process.exit(code);
}

try {
	const ids = initIds();

	const camIp = await getCameraIpAddress(ids);
	if (!camIp) {
		await exit(1);
	}

	setLoginCredentials({
		username,
		password,
		host: camIp!,
	});

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
	ids.suid = suid!;

	// Check if camera contains modded dll
	{
		spinner.start('checking for modded dll');
		const hash = await ftp.getRemoteHash('./FlashBFS/system/common_dll.dll');
		if (hash === crcModdedDll) {
			spinner.succeed('camera contains modded dll');
		} else {
			spinner.fail('camera needs to be modded');
		}
	}

	let done = false;
	while (true) {
		const option = await menu.main();

		switch (option) {
			case MainMenuOption.Backup:
				if (await menu.confirm()) {
					await ftp.downloadToDir(backupPath, './');
				}
				break;

			//case MenuOption.Mod:
			//	await modFiles(backupPath, moddedFilesPath, suid);
			//	break;

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
