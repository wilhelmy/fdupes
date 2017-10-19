-- database for this stuff

CREATE TABLE files(
	basename TEXT NOT NULL,
	dirname TEXT NOT NULL,
	size INTEGER NOT NULL,
	sha256 TEXT, -- may be null if not calculated yet, e.g. because a second file with the same size isn't found yet.
	PRIMARY KEY (basename, dirname)
);
