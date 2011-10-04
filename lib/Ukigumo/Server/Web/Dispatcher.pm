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
use File::Spec;
use Ukigumo::Server::Util;

any '/' => sub {
    my ($c) = @_;

    my %where;
    my $project = $c->req->param('project');
    if ($project) {
        $where{project} = $project;
    }
    my $projects = Ukigumo::Server::Command::Branch->list(%where);

    $c->render( 'index.tt', { projects => $projects, now => time(), project => $project } );
};

get '/project/{project}/{branch:[A-Za-z0-9/_-]+}' => sub {
    my ($c, $args) = @_;
    my $project = $args->{project};
    my $branch = $args->{branch};
    my $page = $c->req->param('page') || 1;
    my $limit = 50;

    my $branch_id = Ukigumo::Server::Command::Branch->find(
        project => $args->{project},
        branch  => $args->{branch},
    );
    my ($reports, $pager) = Ukigumo::Server::Command::Report->list(
        branch_id => $branch_id,
        page      => $page,
        limit     => $limit,
    );
    return $c->render(
        'report_list.tt' => {
            project   => $project,
            branch    => $branch,
            branch_id => $branch_id,
            reports   => $reports,
            pager     => $pager,
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
        return $c->render(
            'show_report.tt',
            {
                report => $report,
                body => Ukigumo::Server::Util::make_line_link( $report->{body} )
            }
        );
    } else {
        return $c->res_404();
    }
};

get '/docs/{path:[a-z0-9_-]+}' => sub {
    my ($c, $args) = @_;
    my $path = $args->{path} // die;
    require Ukigumo::Server::Command::Docs;
    my $html = Ukigumo::Server::Command::Docs->render($path);

    $c->render('docs.tt', {
		doc => $html 
	});
};

1;
