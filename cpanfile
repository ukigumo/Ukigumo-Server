requires 'perl', '5.010001';
requires 'Amon2'                           => '2.50';
requires 'Amon2::Plugin::ShareDir';
requires 'Text::Xslate'                    => '1.1005';
requires 'Plack::Middleware::ReverseProxy' => '0.09';
requires 'POSIX::strftime::Compiler'       => '0.31';
requires 'DBI' => 0;
requires 'DBD::SQLite' => 1.33;
requires 'Data::Validator' => 0.08;
requires 'Plack::Middleware::Session' => 0.14;
requires 'Ukigumo::Common' => '0.07';
requires 'Teng';
requires 'Text::Markdown' => 1;
requires 'Data::Page::NoTotalEntries' => 0.02;
requires 'Locale::Maketext::Lexicon' => 0;
requires 'Time::Duration::Abbreviated' => '0';
requires 'Time::Duration::ja' => '0.03';
requires 'Time::Duration' => 0;
requires 'JSON' => 2;
requires 'Module::Functions';
requires 'Amon2::Declare';
requires 'Amon2::Web';
requires 'Amon2::Web::Dispatcher::Lite';
requires 'Capture::Tiny';
requires 'File::Find::Rule';
requires 'File::ShareDir';
requires 'LWP::UserAgent';
requires 'Locale::Maketext::Extract';
requires 'Plack::Builder';
requires 'Plack::Session::Store::File';
requires 'Router::Simple', '0.14';
requires 'Router::Simple::Sinatraish';
requires 'Text::Xslate::Util';
requires 'URI::Escape';
requires 'URI::WithBase';
requires 'parent';
requires 'Getopt::Long';
requires 'Plack::Loader';
requires 'Pod::Usage';
requires 'Starlet';
requires 'HTML::FromANSI::Tiny', '0.103';
requires 'Compress::Zlib';
requires 'Encode', '2.57';

on 'develop' => sub {
    requires 'Locale::Maketext::Extract::Plugin::Xslate', 'v0.0.2';
    requires 'DBIx::Schema::DSL';
    requires 'SQL::Translator::Producer::Teng';
    requires 'Path::Tiny';
    requires 'Perl::Critic';
    requires 'Test::Perl::Critic';
    requires 'Test::mysqld';
};

on 'test' => sub {
    requires 'Test::Requires' => 0;
    requires 'HTTP::Message::PSGI';
    requires 'LWP::Protocol::PSGI';
    requires 'Test::WWW::Mechanize::PSGI';
    requires 'Plack::Test';
    requires 'Plack::Util';
    requires 'Test::More', '0.98';
    requires 'autodie';

    recommends 'Test::mysqld';
};

on configure => sub {
    requires 'CPAN::Meta';
    requires 'CPAN::Meta::Prereqs';
    requires 'Module::Build';
};
