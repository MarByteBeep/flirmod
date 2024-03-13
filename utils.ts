import { stat, mkdir } from 'node:fs/promises';
import ora from 'ora';
import SelectPrompt from 'enquirer/lib/prompts/select';
import { strict as assert } from 'assert';
import ping from 'ping';

export async function getCameraIpAddress(): Promise<string | undefined> {
	const cameraSerialId = process.env.SERIAL_ID;
	assert.notEqual(cameraSerialId, undefined, 'Missing SERIAL_ID in .env file');

	const camName = `IRCAM${cameraSerialId!.slice(-4)}`;
	spinner.start(`pinging '${camName}' on local network`);
	const pingResult = await ping.promise.probe(camName);
	if (pingResult.numeric_host) {
		spinner.succeed(`camera '${camName}' found at '${pingResult.numeric_host}'`);
	} else {
		spinner.fail(`no camera '${camName}' found with serial '${cameraSerialId}'`);
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

export enum MenuOption {
	Backup = 'backup files',
	//Mod = 'mod',
	Exit = 'exit',
}

export async function displayMenu(): Promise<MenuOption> {
	const prompt = new SelectPrompt({
		name: 'color',
		message: 'select option',
		choices: Object.values(MenuOption),
	});

	return await prompt.run();
}
