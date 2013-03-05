use strict;
use warnings;
use Module::Build::Pluggable qw(CPANfile);

my $build = Module::Build::Pluggable->new(
    license        => 'perl',
    dynamic_config => 0,

    configure_requires => {
        'Module::Build'                      => '0.40',
        'Module::Build::Pluggable::CPANfile' => '0.02',
    },
    build_requires => {},
    requires       => {
        perl => '5.008001',
    },

    no_index    => { 'directory' => [ 'inc' ] },
    name        => 'Ukigumo-Server',
    module_name => 'Ukigumo::Server',

    # script_files => [''],

    test_files           => (-d '.git' || $ENV{RELEASE_TESTING}) ? 't/ xt/' : 't/',
    recursive_test_files => 1,

    meta_merge => {
        resources => {
            repository => 'https://github.com/ukigumo/Ukigumo-Server',
            bugtracker => 'https://github.com/ukigumo/Ukigumo-Server/issues',
        },
    },

    create_readme  => 1,
    create_license => 1,
);

$build->create_build_script();
