package Ukigumo::Server;
use strict;
use warnings;
use 5.010001;
use parent qw(Amon2);
use Carp;
use DBI;
use File::Spec;

__PACKAGE__->load_plugins(qw(ShareDir));

our $VERSION = '0.01';

sub config {
    my ($c, $conf) = @_;
    state $config = $conf || do {
        my $env = $c->mode_name || 'development';
        my $config_base = File::Spec->catdir($c->base_dir, 'config'); # backward compatible
           $config_base = File::Spec->catdir($c->share_dir, 'config') unless -d $config_base;
        my $fname = File::Spec->catfile($config_base, "${env}.pl");
        my $config = do $fname;
        Carp::croak("$fname: $@") if $@;
        Carp::croak("$fname: $!") unless defined $config;
        unless ( ref($config) eq 'HASH' ) {
            Carp::croak("$fname does not return HashRef.");
        }
        $config;
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

