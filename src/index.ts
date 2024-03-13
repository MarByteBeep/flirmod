import * as ftp from './ftp';
import * as telnet from './telnet';
import { modFiles, type SUID } from './firmware';
import { strict as assert } from 'assert';
import * as menu from './menu';
import { MainMenuOption } from './menu';
import { getCameraIpAddress, spinner } from './utils';
import chalk from 'chalk';

const username = 'flir';
const password = '3vlig';

const backupPath = './backup/';
const moddedFilesPath = './modded/';

async function exit(code: number) {
	await ftp.close();
	await telnet.close();
	process.exit(code);
}

try {
	const camIp = await getCameraIpAddress();
	if (!camIp) {
		await exit(1);
	}

	let suid: SUID | undefined = undefined;

	// Connect FTP
	{
		const connected = await ftp.connect(camIp!, username, password);
		if (!connected) {
			await exit(1);
		}

		suid = await ftp.getSUID();
	}

	// Connect Telnet
	{
		const connected = await telnet.connect(camIp!, username, password);
		if (!connected) {
			await exit(1);
		}

		const telnetSuid = await telnet.getSUID();

		// Ensure the suids are identical
		assert.equal(suid, telnetSuid, `mismatch between retreived suids ftp/telnet: '${suid}/${telnetSuid}'`);
	}

	spinner.succeed(`suid: ${chalk.green(suid)}`);

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
			//	await modFiles(backupPath, moddedFilesPath);
			//	break;

			case MainMenuOption.Exit:
				done = true;
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
