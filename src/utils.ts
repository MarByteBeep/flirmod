import { strict as assert } from 'assert';
import { stat, mkdir } from 'node:fs/promises';
import ora from 'ora';
import ping from 'ping';
import chalk from 'chalk';

export async function getCameraIpAddress(): Promise<string | undefined> {
	const cameraSerialId = process.env.SERIAL_ID;
	assert.notEqual(cameraSerialId, undefined, 'Missing SERIAL_ID in .env file');

	const camName = `IRCAM${cameraSerialId!.slice(-4)}`;
	spinner.start(`pinging '${chalk.green(camName)}' on local network`);
	const pingResult = await ping.promise.probe(camName);
	if (pingResult.numeric_host) {
		spinner.succeed(`camera '${chalk.green(camName)}' found at '${chalk.green(pingResult.numeric_host)}'`);
	} else {
		spinner.fail(`no camera '${chalk.green(camName)}' found with serial '${chalk.green(cameraSerialId)}'`);
	}
	return pingResult.numeric_host;
}

export async function sleep(ms: number) {
	return new Promise((resolve) => setTimeout(resolve, ms));
}

export async function ensureLocalDirectory(path: string) {
	try {
		await stat(path);
	} catch (err) {
		await mkdir(path, { recursive: true });
	}
}

export const spinner = ora({
	color: 'green',
});
