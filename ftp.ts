import { Client } from 'basic-ftp/dist';
import { join } from 'node:path';
import { ensureLocalDirectory, spinner } from './utils';
import { strict as assert } from 'assert';

let client: Client | undefined = undefined;

type Stats = {
	total: number;
	success: number;
	failed: string[];
};

async function downloadFromWorkingDir(localDirPath: string, stats?: Stats) {
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

export async function connect(host: string, username: string, password: string): Promise<boolean> {
	assert.equal(client, undefined);

	spinner.start(`connect to '${host}':21`);
	client = new Client();
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
		spinner.succeed(`connected to ${host}:21`);
		return true;
	} catch (err: any) {
		spinner.fail(`failed to connect to ${host}:21, reason: ${err.message}'`);
	}
	close();
	return false;
}

export async function close() {
	if (client) {
		client.close();
		client = undefined;
	}
}
