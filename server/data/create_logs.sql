CREATE TABLE IF NOT EXISTS logs (
	id INTEGER PRIMARY KEY,	/* Becomes ROWID() */
	timestamp INTEGER NOT NULL,
	level TEXT NOT NULL,
	message TEXT NOT NULL,
	statusCode INTEGER NOT NULL,
	duration INTEGER,
	accountId TEXT,
	sessionId TEXT,
	stack TEXT,
	request TEXT,
	body TEXT
);

CREATE TABLE IF NOT EXISTS notifications (
	id INTEGER PRIMARY KEY,	/* Becomes ROWID() */
	timestamp INTEGER NOT NULL,
	logId INTEGER NOT NULL,
	statusCode INTEGER NOT NULL,
	message TEXT NOT NULL
);
