CREATE TABLE IF NOT EXISTS branch (
    branch_id INTEGER NOT NULL PRIMARY KEY,
    project        VARCHAR(255) NOT NULL,
    branch         VARCHAR(255) NOT NULL,
    last_report_id INTEGER DEFAULT NULL,
    ctime          INT UNSIGNED NOT NULL,
    UNIQUE (project, branch)
);

CREATE TABLE IF NOT EXISTS report (
    report_id INTEGER NOT NULL PRIMARY KEY,
    branch_id INTEGER NOT NULL,
    status    TINYINT UNSIGNED NOT NULL, -- 1: success, 2: fail, 3:na
    repo      TEXT,
    revision  VARCHAR(255),
    vc_log    TEXT,
    body      TEXT,
    ctime     INT UNSIGNED NOT NULL,
    FOREIGN KEY (branch_id) REFERENCES branch (branch_id) ON DELETE CASCADE
);
