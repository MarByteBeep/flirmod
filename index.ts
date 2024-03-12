import { expect } from 'bun:test';
import { promise as ping } from 'ping';
import * as ftp from './ftp';
import { modFiles } from './firmware';

const cameraSerialId = process.env.SERIAL_ID;
expect(cameraSerialId).toBeDefined();

const username = 'flir';
const password = '3vlig';

const backupPath = './backup/';
const modifiedPath = './modded/';

async function getCameraIpAddress(serialId: string): Promise<string | undefined> {
	const camName = `IRCAM${serialId.slice(-4)}`;
	console.log(`pinging '${camName}' on local network`);
	const pingResult = await ping.probe(camName);
	return pingResult.numeric_host;
}

const camIp = await getCameraIpAddress(cameraSerialId!);
if (!camIp) {
	console.error(`no camera found with serial ${cameraSerialId}`);
	process.exit(1);
}
console.info(`camera found @ '${camIp}'`);

const connected = await ftp.connect(camIp, username, password);
if (!connected) {
	console.error(`cannot connect to camera FTP server`);
	process.exit(1);
}
console.info(`connected to camera FTP server`);
try {
	await ftp.downloadToDir(backupPath, './');
	await modFiles(backupPath, modifiedPath);
} catch (e: any) {
	console.error(e.message);
	ftp.close();
	process.exit(1);
}

ftp.close();
process.exit(0);
