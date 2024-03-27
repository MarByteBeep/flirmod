import { strict as assert } from 'assert';
import chalk from 'chalk';
import ora from 'ora';
import ping from 'ping';
import { AppSettings } from './AppSettings';
import * as ftp from './ftp';
import * as telnet from './telnet';
import type { CamIDs } from './types';

export async function restartCamera(): Promise<void> {
	const minBootTime = 40000;
	const maxReconnectionAttempts = 5;

	spinner.start(`restarting camera`);
	await sleep(1000);

	spinner.suffixText = '- closing ftp';
	await ftp.close();

	spinner.suffixText = '- sending restart command';
	try {
		await telnet.exec(`restart`);
	} catch (e: any) {
		if (e.message !== 'response not received') {
			spinner.fail(`failed to restart camera`);
			return;
		}
	}
	await telnet.close();

	spinner.suffixText = '- waiting for camera to restart';
	await sleep(minBootTime);
	let tries = 0;
	while (tries < maxReconnectionAttempts) {
		spinner.suffixText = `- reconnection attempt ${tries + 1}`;
		const ftpConnected = await ftp.connect(true);
		if (ftpConnected) {
			const telnetConnected = await telnet.connect(true);
			if (ftpConnected && telnetConnected) {
				spinner.suffixText = '';
				spinner.succeed(`camera restarted`);
				return;
			}
		}
		await sleep(5000);
		tries++;
	}
	spinner.fail('failed to reconnect to camera');
}

/**
 * Retrieves the IP address of a camera if it is found on the local network.
 * @param ids - An object containing the camera IDs.
 * @returns The IP address of the camera if it is found, or undefined if it is not found.
 */
export async function getCameraIpAddress(): Promise<string | undefined> {
	const serial = AppSettings.Camera.SerialId;
	const camName = `IRCAM${serial.slice(-4)}`;
	spinner.start(`pinging '${chalk.green(camName)}' on local network`);
	const pingResult = await ping.promise.probe(camName);
	if (pingResult.numeric_host) {
		spinner.succeed(`camera '${chalk.green(camName)}' found at '${chalk.green(pingResult.numeric_host)}'`);
	} else {
		spinner.fail(`no camera '${chalk.green(camName)}' found with serial '${chalk.green(serial)}'`);
	}
	return pingResult.numeric_host;
}

/**
 * Pauses the execution of the code for a specified amount of time.
 * @param ms The number of milliseconds to pause the code execution.
 * @returns A Promise that resolves after the specified number of milliseconds.
 */
export async function sleep(ms: number): Promise<void> {
	return new Promise((resolve) => setTimeout(resolve, ms));
}

export const spinner = ora({
	color: 'green',
});
