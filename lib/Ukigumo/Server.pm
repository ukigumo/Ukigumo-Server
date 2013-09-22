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
    state $config = do {
        my $plack_env = $ENV{PLACK_ENV} // 'development';

        die 'Characters in $ENV{PLACK_ENV} must be alnum, hiphen or underscore' if $plack_env =~ /[^-_0-9a-zA-Z]/;
        +{
            'DBI' => [
                "dbi:SQLite:dbname=$plack_env.db",
                '',
                '',
                +{
                    sqlite_unicode => 1,
                }
            ],
        }
    }
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

