import { Telnet } from 'telnet-client';
import { spinner } from './utils';
import { strict as assert } from 'assert';
import chalk from 'chalk';

let client: Telnet | undefined = undefined;

/**
 * Executes a command on a Telnet client and returns the result as an array of strings.
 * @param command - The command to be executed on the Telnet client.
 * @returns An array of strings representing the lines of the command execution result.
 * @throws {AssertionError} If the client is not defined or the result is invalid.
 */
async function exec(command: string): Promise<string[]> {
	assert.notEqual(client, undefined, 'Client is not defined.');

	const result = await client!.exec(command);
	const lines = result.trim().split('\n');

	assert(lines.length >= 2, 'Invalid result length.');
	assert(lines[0] === command, 'First line should contain command.');

	// Axe the command (first line) from the result
	lines.shift();
	return lines;
}

/**
 * Retrieves a unique identifier (SUID) by executing a command through a Telnet client.
 * @returns {Promise<string>} The SUID, which is a string representing a unique identifier.
 */
export async function getSUID(): Promise<string> {
	const res = await exec('suid');
	assert(res.length === 1, 'Expected result length to be 1');

	const regex = /^[0-9A-F]{16}$/;

	assert(regex.test(res[0]), `SUID '${res[0]}' failed to pattern match`);

	return res[0];
}

/**
 * Establishes a Telnet connection to a specified host.
 * @param host - The IP address or hostname of the remote host.
 * @param username - The username to use for authentication.
 * @param password - The password to use for authentication.
 * @returns A boolean value indicating whether the connection was successful or not.
 */
export async function connect(host: string, username: string, password: string): Promise<boolean> {
	const port = 23;
	assert.equal(client, undefined);

	const formatted = chalk.green(`${host}:${port}`);

	spinner.start(`telnet: connect to '${formatted}'`);

	client = new Telnet();

	const params = {
		host: host,
		port: port,
		shellPrompt: /\\>/,
		timeout: 3000,
	};

	try {
		await client.connect(params);
		spinner.succeed(`telnet: connected to '${formatted}'`);
		return true;
	} catch (err: any) {
		spinner.fail(
			`failed to connect to '${formatted}', reason: ${chalk.yellow(err.message)}, try rebooting your camera.`
		);
	}
	close();
	return false;
}

/**
 * Closes the Telnet connection.
 */
export async function close() {
	if (client) {
		await client.end();
		await client.destroy();
		client = undefined;
	}
}
