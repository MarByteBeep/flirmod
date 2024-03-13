import { Telnet } from 'telnet-client';
import { sleep, spinner } from './utils';
import { strict as assert } from 'assert';
import chalk from 'chalk';

let client: Telnet | undefined = undefined;

async function exec(command: string): Promise<string[]> {
	assert.notEqual(client, undefined);

	const result = await client!.exec(command);

	const lines = result.trim().split('\n');
	assert(lines.length >= 2);
	assert(lines[0] === command);

	// Axe the command (first line) from the result
	lines.shift();
	return lines;
}

export async function suid() {
	const res = await exec('suid');
	assert(res.length === 1);

	const regex = /[0-9A-F]{16}/g;

	assert(regex.test(res[0]), `suid '${res[0]}' failed to pattern match`);

	return res[0];
}

export async function connect(host: string, username: string, password: string): Promise<boolean> {
	const port = 23;
	assert.equal(client, undefined);

	spinner.start(`telnet: connect to '${host}:${port}'`);

	client = new Telnet();

	const params = {
		host: host,
		port: port,
		shellPrompt: /\\>/,
		timeout: 4500,
	};

	try {
		await client.connect(params);
		spinner.succeed(`telnet: connected to '${host}:${port}'`);
		return true;
	} catch (err: any) {
		spinner.fail(`failed to connect to '${host}:${port}', reason: ${chalk.yellow(err.message)}`);
	}
	close();
	return false;
}

export async function close() {
	if (client) {
		await client.end();
		await client.destroy();
		client = undefined;
	}
}
