import { strict as assert } from 'assert';

export type LoginCredentials = {
	host: string;
	username: string;
	password: string;
};

let storedCredentials: LoginCredentials | undefined = undefined;

export function setLoginCredentials(credentials: LoginCredentials) {
	assert.equal(storedCredentials, undefined);
	storedCredentials = credentials;
}

export function getLoginCredentials(): LoginCredentials {
	assert.notEqual(storedCredentials, undefined);
	return storedCredentials!;
}
