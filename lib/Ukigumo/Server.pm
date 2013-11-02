package Ukigumo::Server;
use strict;
use warnings;
use 5.010001;
use version; our $VERSION = version->declare('v1.0.1');

use parent qw(Amon2);
use Carp;
use DBI;
use File::ShareDir;
use File::Spec;

use Ukigumo::Server::DB;

__PACKAGE__->load_plugins(qw(ShareDir));

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
        $conf->[3]->{RaiseError}        = 1;
        $conf->[3]->{sqlite_unicode}    = 1 if $self->dbdriver eq 'sqlite';
        $conf->[3]->{mysql_enable_utf8} = 1 if $self->dbdriver eq 'mysql';
        DBI->connect(@$conf) or die $DBI::errstr;
    };
}

sub db {
    my $self = shift;
    $self->{db} ||= Ukigumo::Server::DB->new(dbh => $self->dbh);
}

sub dbdriver {
    my $self = shift;

    $self->{dbdriver} ||= do {
        my $conf = $self->config->{DBI} or die "Missing configuration for DBI";
        my $dsn0 = $conf->[0];
        my $db
            = $dsn0 =~ /:mysql:/ ? 'MySQL'
            : $dsn0 =~ /:Pg:/    ? 'PostgreSQL'
            :                      do { my ($d) = $dsn0 =~ /dbi:(.*?):/; $d };
        lc $db;
    };
}

sub setup_schema {
    my $self = shift;
    my $f = lc $self->dbdriver . '.sql';
    my $fname = File::Spec->catfile($self->share_dir , 'sql', $f);
    unless (-f $fname) {
        # Resolve real share_dir. User himself might create 'share/' dir in current directory.
        my $real_share = File::ShareDir::dist_dir('Ukigumo-Server');
        $fname = File::Spec->catfile($real_share, 'sql', $f);
    }
    my $schema = do {
        local $/;
        open my $fh, '<', $fname or die "Cannot open $fname: $!";
        <$fh>
    };
    for my $code (split /;/, $schema) {
        next if $code =~ /^$/;
        $self->dbh->do( $code );
    }
}

1;
__END__

=encoding utf-8

=head1 NAME

Ukigumo::Server - Testing report storage Server

=head1 SYNOPSIS

    % ukigumo-server

=head1 DESCRIPTION

Ukigumo::Server is testing report storage server. You can use this server for Continious Testing.

=begin html

<img src="http://gyazo.64p.org/image/dbd98bc15032d97fab081a271541baa2.png" alt="Screen shot">

=end html

=head1 INSTALLATION

    % cpanm Ukigumo::Server
    % ukigumo-server
    ukigumo-server starts listen on 0:2828

Or you can use git repo instead of C<< cpanm Ukigumo::Server >> for launching L<Ukigumo::Server>.

    % git clone git@github.com:ukigumo/Ukigumo-Server.git .
    # install carton to your system
    % curl -L http://cpanmin.us | perl - Carton
    # And setup the depended modules.
    % carton install
    # Then, run the http server!
    % carton exec perl local/bin/ukigumo-server

=head1 SEE ALSO

L<ukigumo-server>

=head1 LICENSE

Copyright (C) tokuhirom.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

tokuhirom E<lt>tokuhirom@gmail.comE<gt>

=cut

