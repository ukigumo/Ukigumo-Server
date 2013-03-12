requires 'Amon2'                           => '2.50';
requires 'Text::Xslate'                    => '1.1005';
requires 'Text::Xslate::Bridge::TT2Like'   => '0.00008';
requires 'Plack::Middleware::ReverseProxy' => '0.09';
requires 'Time::Piece'                     => '1.20';
requires 'SQL::Interp' => 0;
requires 'DBI' => 0;
requires 'DBD::SQLite' => 1.33;
requires 'Data::Validator' => 0.08;
requires 'Plack::Middleware::Session' => 0.14;
requires 'Ukigumo::Common' => '0.03';
requires 'Text::Markdown' => 1;
requires 'Data::Page::NoTotalEntries'     => 0.02;
requires 'Locale::Maketext::Lexicon' => 0;
requires 'Time::Duration::ja' => 0;
requires 'Time::Duration' => 0;
requires 'JSON' => 2;
requires 'Module::Functions';

on 'test' => sub {
    requires 'Test::Requires' => 0;
};
