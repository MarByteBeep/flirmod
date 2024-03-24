import { Client } from 'basic-ftp/dist';
import { join } from 'node:path';
import { ensureLocalDirectory, spinner } from './utils';
import { strict as assert } from 'assert';
import MemoryStream from 'memorystream';
import chalk from 'chalk';
import type { SUID } from './firmware';
import { getLoginCredentials } from './logincredentials';

let client: Client | undefined = undefined;

type Stats = {
	total: number;
	success: number;
	failed: string[];
};

/**
 * Downloads a file from an FTP server and stores it in memory.
 * @param path - The path of the file to be downloaded from the FTP server.
 * @param encoding - The encoding to be used when converting the downloaded file to a string. If not provided, the file will be returned as a Buffer.
 * @returns The downloaded file as a Buffer or a string, depending on the presence of the encoding.
 * @throws If the download fails or if the client is not defined.
 */
export async function downloadFileInMemory(path: string, encoding?: BufferEncoding): Promise<Buffer | string> {
	assert.notEqual(client, undefined, 'Client is not defined.');

	const stream = new MemoryStream();
	try {
		await client!.downloadTo(stream, path);
	} catch (_) {
		stream.end();
		throw new Error(`${path}: download failed`);
	}

	stream.end();

	const chunks: Buffer[] = [];
	for await (const chunk of stream) {
		chunks.push(Buffer.from(chunk));
	}

	if (encoding) {
		return Buffer.concat(chunks).toString(encoding);
	}

	return Buffer.concat(chunks);
}

/**
 * Retrieves a unique identifier (SUID) from a file on an FTP server.
 * The SUID is extracted from the contents of the file using a regular expression pattern match.
 * @returns The SUID value extracted from the file.
 */
export async function getSUID(): Promise<SUID> {
	assert.notEqual(client, undefined, 'client is not defined');

	const file = (await downloadFileInMemory('/FlashIFS/version.rsc', 'ascii')) as string | undefined;

	const re = /^\.version\.SUID text "([0-9A-F]{16})"$/gm;

	const suid = re.exec(file ?? '')?.at(1);

	assert.notEqual(suid, undefined, `couldn't pattern match suid`);

	// ensure the camera version is 'E4 2.0L'
	{
		const re = /^\.version\.kits\.confkit\.ver text "([A-Z\s0-9\.]+)"$/gm;
		const version = re.exec(file ?? '')?.at(1);
		assert.equal(
			version,
			'E4 2.0L',
			`this patch only works on camera version: 'E4 2.0L', camera version: '${version}'.`
		);
	}

	// also ensure the firmware version is '3.16.0'
	{
		const re = /^\.version\.swcombination\.ver text "([0-9\.]+)"$/gm;
		const version = re.exec(file ?? '')?.at(1);
		assert.equal(
			version,
			'3.16.0',
			`required firmware version: '3.16.0', camera firmware version: '${version}'. ` +
				`Update your camera to firmware version '3.16.0'.`
		);
	}

	return suid!;
}

/**
 * Recursively downloads files from a remote directory to a local directory using an FTP client.
 * @param localDirPath The path to the local directory where the files will be downloaded.
 * @param stats The statistics object to track the number of files processed and failed.
 * @returns A Promise that resolves when all files have been downloaded.
 */
async function downloadFromWorkingDir(localDirPath: string, stats?: Stats): Promise<void> {
	assert.notEqual(client, undefined);
	assert.equal(client?.closed, false);
	if (!stats) {
		stats = {
			total: 0,
			success: 0,
			failed: [],
		};
	}

	const list = await client!.list();

	await ensureLocalDirectory(localDirPath);
	for (const file of list) {
		const localPath = join(localDirPath, file.name);
		if (file.isDirectory) {
			await client!.cd(file.name);
			await downloadFromWorkingDir(localPath, stats);
			await client!.cdup();
		} else if (file.isFile) {
			stats.total++;
			try {
				await client!.downloadTo(localPath, file.name);
				stats.success++;
			} catch {
				stats.failed.push(localPath);
			}
		}
		spinner.suffixText = `${stats.total} (${stats.failed.length} failed) - ${localPath}`;
	}
}

/**
 * Downloads files from a remote directory to a local directory.
 * @param localDirPath The path to the local directory where the files will be downloaded.
 * @param remoteDirPath The path to the remote directory from where the files will be downloaded.
 */
export async function downloadToDir(localDirPath: string, remoteDirPath?: string) {
	assert.notEqual(client, undefined);
	assert.equal(client?.closed, false);

	spinner.start('downloading files');

	if (remoteDirPath) {
		await client!.cd(remoteDirPath);
	}

	await downloadFromWorkingDir(localDirPath);

	spinner.succeed();
}

export async function connect(silent: boolean = false): Promise<boolean> {
	const port = 21;
	assert.equal(client, undefined);

	const { host, username, password } = getLoginCredentials();

	const formatted = chalk.green(`${host}:${port}`);

	if (!silent) spinner.start(`ftp: connect to '${formatted}'`);
	client = new Client(3000);
	client.ftp.verbose = false;
	// Server doesn't support 'LIST -a'
	client.availableListCommands = ['LIST'];
	try {
		await client.connect(host, 21);
		await client.login(username, password);
		const cwd = await client.send('PWD'); // Current working directory should be /
		assert.equal(cwd.code, 257);
		assert.equal(cwd.message, '257 "/".');

		await client.send('TYPE I'); // Binary mode
		if (!silent) spinner.succeed(`ftp: connected to '${formatted}'`);
		return true;
	} catch (err: any) {
		if (!silent)
			spinner.fail(
				`failed to connect to '${formatted}', reason: ${chalk.yellow(err.message)}, try rebooting your camera.`
			);
	}
	close();
	return false;
}

/**
 * Closes the FTP client connection.
 */
export async function close() {
	if (client) {
		client.close();
		client = undefined;
	}
}
