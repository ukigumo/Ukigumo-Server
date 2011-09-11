package Ukigumo::Server::Web::Dispatcher;
use strict;
use warnings;
use 5.010001;
use Amon2::Web::Dispatcher::Lite;
use SQL::Interp qw(:all);
use URI::Escape qw(uri_unescape);
use Time::Piece;
use Ukigumo::Server::Command::Report;
use Ukigumo::Server::Command::Branch;
use Data::Validator;
use Text::Xslate::Util qw(mark_raw);

any '/' => sub {
    my ($c) = @_;

    my %where;
    if (my $project = $c->req->param('project')) {
        $where{project} = $project;
    }
    my $projects = Ukigumo::Server::Command::Branch->list(%where);

    $c->render( 'index.tt', { projects => $projects, now => time() } );
};

get '/project/{project}/{branch}' => sub {
    my ($c, $args) = @_;
    my $project = $args->{project};
    my $branch = $args->{branch};

    my $branch_id = Ukigumo::Server::Command::Branch->find(
        project => $args->{project},
        branch  => $args->{branch},
    );
    my $reports = Ukigumo::Server::Command::Report->list(
        branch_id => $branch_id,
        limit     => 50,
    );
    return $c->render(
        'report_list.tt' => {
            project   => $project,
            branch    => $branch,
            branch_id => $branch_id,
            reports   => $reports,
        }
    );
};

get '/branch/delete' => sub {
    my ($c, $args) = @_;

    my $branch_id = $c->req->param('branch_id') || die;
    my $branch = Ukigumo::Server::Command::Branch->lookup(
        branch_id => $branch_id,
    ) or die "Unknown branch: $branch_id";
    return $c->render(
        'branch_delete.tt' => {
            branch  => $branch,
        }
    );
};
post '/branch/delete' => sub {
    my ($c, $args) = @_;

    my $branch_id = $c->req->param('branch_id') || die;
    Ukigumo::Server::Command::Branch->delete(
        branch_id => $branch_id,
    );
    return $c->redirect('/');
};

get '/report/{report_id:\d+}' => sub {
    my ($c, $args) = @_;
    my $report_id = $args->{report_id};
    my $report = Ukigumo::Server::Command::Report->find( report_id => $report_id );
    if ($report) {
        return $c->render('show_report.tt', {report => $report});
    } else {
        return $c->res_404();
    }
};

get '/docs/about' => sub {
    my $c = shift;

    $c->render('docs/about.tt', {
		doc => do {
			require Text::Xatena; # lazy load
			my $src = do {
				open my $fh, '<:utf8', 'docs/about.txt' or die "Cannot open file: docs/about.txt: $!";
				do { local $/; <$fh> };
			};
			my $tnx = Text::Xatena->new();
			my $doc = $tnx->format($src);
			mark_raw($doc)
		}
	});
};

1;
