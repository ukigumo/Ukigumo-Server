use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'Ukigumo::Server',
    AUTHOR        => 'Some Person <person@example.com>',
    VERSION_FROM  => 'lib/Ukigumo/Server.pm',
    PREREQ_PM     => {
        'Amon2'                           => '2.50',
        'Text::Xslate'                    => '1.1005',
        'Text::Xslate::Bridge::TT2Like'   => '0.00008',
        'Plack::Middleware::ReverseProxy' => '0.09',
        'HTML::FillInForm::Lite'          => '1.09',
        'Time::Piece'                     => '1.20',
    },
    MIN_PERL_VERSION => '5.008001',
    (-d 'xt' and $ENV{AUTOMATED_TESTING} || $ENV{RELEASE_TESTING}) ? (
        test => {
            TESTS => 't/*.t xt/*.t',
        },
    ) : (),
);
