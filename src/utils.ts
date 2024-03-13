import { strict as assert } from 'assert';
import { stat, mkdir } from 'node:fs/promises';
import ora from 'ora';
import ping from 'ping';
import chalk from 'chalk';
import type { CamIDs } from './firmware';

export async function getCameraIpAddress(ids: CamIDs): Promise<string | undefined> {
	const camName = `IRCAM${ids.serial.slice(-4)}`;
	spinner.start(`pinging '${chalk.green(camName)}' on local network`);
	const pingResult = await ping.promise.probe(camName);
	if (pingResult.numeric_host) {
		spinner.succeed(`camera '${chalk.green(camName)}' found at '${chalk.green(pingResult.numeric_host)}'`);
	} else {
		spinner.fail(`no camera '${chalk.green(camName)}' found with serial '${chalk.green(ids.serial)}'`);
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

export function initIds(): CamIDs {
	const ids: CamIDs = {
		serial: process.env.SERIAL_ID ?? '',
		suid: 'XXXXXXXXXXXXXXXX', // Will be fetched later through ftp and telnet
	};

	assert.notEqual(ids.serial, '', 'Missing SERIAL_ID in .env file');

	assert.equal(
		ids.serial.length,
		9,
		`Incorrect SERIAL_ID in .env file, '${ids.serial}' should be a string of 9 digits, ` +
			`but has length ${ids.serial.length}`
	);

	const regex = /^\d{9}$/;
	assert.ok(regex.test(ids.serial), `Incorrect SERIAL_ID in .env file, '${ids.serial}' should only contain digits`);

	return ids;
}

export const spinner = ora({
	color: 'green',
});
