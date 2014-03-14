+{
    'DBI' => [
        'dbi:SQLite:dbname=' . (-d '/home/dotcloud/' ? '/home/dotcloud/ukigumo.db' : 'deployment.db'),
        '',
        '',
        +{
            sqlite_unicode => 1,
        }
    ],

    max_num_of_reports_by_branch => 1000,
    max_num_of_reports => 5000,
};
