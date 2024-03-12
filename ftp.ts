import { expect } from 'bun:test';
import { Client } from 'basic-ftp';
import { join } from 'node:path';
import { ensureLocalDirectory } from './utils';

let client: Client | undefined = undefined;

async function downloadFromWorkingDir(localDirPath: string) {
	expect(client).toBeDefined();
	expect(client?.closed).toBe(false);

	const list = await client!.list();

	await ensureLocalDirectory(localDirPath);
	for (const file of list) {
		const localPath = join(localDirPath, file.name);
		if (file.isDirectory) {
			await client!.cd(file.name);
			await downloadFromWorkingDir(localPath);
			await client!.cdup();
		} else if (file.isFile) {
			try {
				await client!.downloadTo(localPath, file.name);
				console.log(localPath);
			} catch {
				console.error(`failed: '${localPath}'`);
			}
		}
	}
}

export async function downloadToDir(localDirPath: string, remoteDirPath?: string) {
	expect(client).toBeDefined();
	expect(client?.closed).toBe(false);

	//const userDir = await client.pwd();
	if (remoteDirPath) {
		await client!.cd(remoteDirPath);
	}

	return await downloadFromWorkingDir(localDirPath);
}

export async function connect(host: string, username: string, password: string): Promise<boolean> {
	expect(client).toBeUndefined();

	client = new Client();
	client.ftp.verbose = false;
	try {
		await client.connect(host, 21);
		await client.login(username, password);
		const cwd = await client.send('PWD'); // Current working directory should be /
		expect(cwd.code).toBe(257);
		expect(cwd.message).toBe('257 "/".');
		await client.send('TYPE I'); // Binary mode
		return true;
	} catch (err) {
		console.log(err);
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
