use strict;
use warnings;
use utf8;
use 5.010001;

package Ukigumo::Server;
use parent qw(Amon2);
use File::Spec;
use DBI;
__PACKAGE__->load_plugins(qw(ShareDir));

our $VERSION='0.01';

sub config {
    my $c = shift;
    state $config = do {
        my $env = $c->mode_name // 'development';
        my $fname = File::Spec->catfile($c->base_dir, 'config', "${env}.pl");

        my $conf;
        if (-e $fname) {
            $conf = do $fname;
            Carp::croak("$fname: $@") if $@;
            Carp::croak("$fname: $!") unless defined $conf;
            unless ( ref($conf) eq 'HASH' ) {
                Carp::croak("$fname does not return HashRef.");
            }
        }
        else {
            die 'Characters in $ENV{PLACK_ENV} must be alnum, hyphen or underscore' if $env =~ /[^-_0-9a-zA-Z]/;
            my $db = "$env.db";
            print qq[Config file: "$fname" is not available. Use $db for launching ukigumo server\n];
            $conf = {
                'DBI' => [
                    "dbi:SQLite:dbname=$db",
                    '',
                    '',
                    +{
                        sqlite_unicode => 1,
                    }
                ],
            };
        }
        $conf;
    };
}

sub dbh {
    my $self = shift;

    $self->{dbh} ||= do {
        my $conf = $self->config->{DBI} or die "Missing configuration for DBI";
        $conf->[3]->{RaiseError}     = 1;
        $conf->[3]->{sqlite_unicode} = 1;
        DBI->connect(@$conf) or die $DBI::errstr;
    };
}

sub setup_schema {
    my $self = shift;
    my $fname = File::Spec->catfile($self->share_dir , 'sql', 'sqlite3.sql');
    open my $fh, '<', $fname or die "Cannot open $fname: $!";
    my $schema = do { local $/; <$fh> };
    for my $code (split /;/, $schema) {
        $self->dbh->do( $code );
    }
}

1;
__END__

=encoding utf-8

=head1 NAME

Ukigumo::Server - Testing report storage Server

=head1 DESCRIPTION

Ukigumo::Server is ...

=head1 LICENSE

Copyright (C) tokuhirom.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

tokuhirom E<lt>tokuhirom@gmail.comE<gt>

=cut

