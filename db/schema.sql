
CREATE TABLE page (
	id INTEGER PRIMARY KEY,
	title TEXT,
	body TEXT,
	created_at DATETIME NOT NULL,
	modified_at DATETIME NOT NULL
);
CREATE INDEX index_page_title ON page (title);
CREATE INDEX index_page_created_at ON page (created_at);

CREATE TABLE page_history (
	id INTEGER PRIMARY KEY,
	page_id INTEGER,
	body TEXT,
	created_at DATETIME NOT NULL
);
CREATE INDEX index_page_history_created_at ON page_history (created_at);

