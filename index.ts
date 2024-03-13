import * as ftp from './ftp';
import * as telnet from './telnet';
import { modFiles } from './firmware';
import { strict as assert } from 'assert';
import { MenuOption, displayMenu, getCameraIpAddress, spinner } from './utils';

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

	let suid: string | undefined = undefined;

	// Connect FTP
	{
		const connected = await ftp.connect(camIp!, username, password);
		if (!connected) {
			await exit(1);
		}

		suid = await ftp.suid();
	}

	// Connect Telnet
	{
		const connected = await telnet.connect(camIp!, username, password);
		if (!connected) {
			await exit(1);
		}

		const telnetSuid = await telnet.suid();

		// Ensure the suids are identical
		assert.equal(suid, telnetSuid, `mismatch between retreived suids ftp/telnet: '${suid}/${telnetSuid}'`);
	}

	spinner.succeed(`retrieved and verified suid: ${suid}`);

	let done = false;
	while (true) {
		const option = await displayMenu();

		switch (option) {
			case MenuOption.Backup:
				await ftp.downloadToDir(backupPath, './');
				break;

			//case MenuOption.Mod:
			//	await modFiles(backupPath, moddedFilesPath);
			//	break;

			case MenuOption.Exit:
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
	// FIXME: Color error message
	console.error(e);
	await exit(1);
}

await exit(0);
