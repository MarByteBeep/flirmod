import * as ftp from './ftp';
import { modFiles } from './firmware';
import { MenuOption, displayMenu, exit, getCameraIpAddress, spinner } from './utils';
import { strict as assert } from 'assert';

const username = 'flir';
const password = '3vlig';

const backupPath = './backup/';
const moddedFilesPath = './modded/';

try {
	const camIp = await getCameraIpAddress();
	if (!camIp) {
		exit(1);
	}

	const connected = await ftp.connect(camIp!, username, password);
	if (!connected) {
		exit(1);
	}

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
	ftp.close();
	exit(1);
}

ftp.close();
exit(0);
