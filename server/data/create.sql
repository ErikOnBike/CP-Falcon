CREATE TABLE IF NOT EXISTS accounts (
	id TEXT NOT NULL PRIMARY KEY,	/* Never shared with user(s) */
	createdAt INTEGER NOT NULL,
	updatedAt INTEGER,
	deletedAt INTEGER,
	activatedAt INTEGER,
	email TEXT NOT NULL UNIQUE,
	password TEXT NOT NULL,		/* Hash of course */
	settings TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS activations (
	id TEXT NOT NULL PRIMARY KEY,
	email TEXT NOT NULL,
	token TEXT NOT NULL,
	expiresAt INTEGER NOT NULL
);
CREATE TABLE IF NOT EXISTS sessions (
	id TEXT NOT NULL PRIMARY KEY,
	createdAt INTEGER NOT NULL,
	updatedAt INTEGER,
	accountId TEXT NOT NULL,
	accessToken TEXT NOT NULL UNIQUE,
	expires TEXT NOT NULL		/* 'usage', 'day' or 'never' */
);
CREATE TABLE IF NOT EXISTS repositories (
	id TEXT NOT NULL PRIMARY KEY,
	createdAt INTEGER NOT NULL,
	updatedAt INTEGER,
	deletedAt INTEGER,
	name TEXT NOT NULL,
	location TEXT NOT NULL,
	syncedAt INTEGER
);
