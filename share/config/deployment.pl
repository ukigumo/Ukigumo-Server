+{
    'DBI' => [
        'dbi:SQLite:dbname=' . (-d '/home/dotcloud/' ? '/home/dotcloud/ukigumo.db' : 'deployment.db'),
        '',
        '',
        +{
            sqlite_unicode => 1,
        }
    ],

    max_report_size_by_branch => 1000,
    max_report_size => 5000,
};
