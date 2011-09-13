+{
    'DBI' => [
        'dbi:SQLite:dbname=' . (-f '/home/dotcloud/' ? '/home/dotcloud/ukigumo.db' : 'deployment.db'),
        '',
        '',
        +{
            sqlite_unicode => 1,
        }
    ],
};
