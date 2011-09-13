+{
    'DBI' => [
        'dbi:SQLite:dbname=' . (-d '/home/dotcloud/' ? '/home/dotcloud/ukigumo.db' : 'deployment.db'),
        '',
        '',
        +{
            sqlite_unicode => 1,
        }
    ],
};
