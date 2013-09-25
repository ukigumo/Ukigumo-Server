# MUST do CREATE DATABASE ukigumo before run ukigumo-server
+{
    'DBI' => [
        'dbi:mysql:dbname=ukigumo:host=127.0.0.1',
        'scott', # user
        'tiger', # password
        +{
        }
    ],
};
