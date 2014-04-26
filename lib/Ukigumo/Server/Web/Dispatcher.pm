package Ukigumo::Server::Web::Dispatcher;
use strict;
use warnings;
use 5.010001;
use Amon2::Web::Dispatcher::Lite;
use URI::Escape qw(uri_unescape uri_escape);
use Ukigumo::Server::Command::Report;
use Ukigumo::Server::Command::Branch;
use Data::Validator;
use File::Spec;
use Ukigumo::Server::Util;
use JSON qw(encode_json);
use Text::Xslate qw(mark_raw);

any '/' => sub {
    my ($c) = @_;

    my $project = $c->req->param('project');
    if ($project) {
        return $c->redirect('/project/' . uri_escape($project));
    }
    my $project_src = Ukigumo::Server::Command::Branch->list();
    my %projects = ();
    for my $project (@$project_src) {
        push @{$projects{$project->{project}}}, $project;
    }

    $c->render( 'index.tx',
        {
            now => time(),
            projects => \%projects,
        }
    );
};

# CruiseControl format XML http://cruisecontrol.sourceforge.net/
get '/cc.xml' => sub {
    my ($c) = @_;

    my $project_src = Ukigumo::Server::Command::Branch->list();
    my %projects = ();
    for my $project (@$project_src) {
        push @{$projects{$project->{project}}}, $project;
    }

    my $res = $c->render( 'cc.xml.tx',
        {
            now => time(),
            projects => \%projects,
        }
    );
    $res->content_type( 'application/xml' );
    $res;
};

get '/rss.xml' => sub {
    my ($c, $args) = @_;

    my $limit = 50;

    my ($reports, $pager) = Ukigumo::Server::Command::Report->recent_list(
        limit     => $limit,
    );
    for my $report (@{$reports}) {
        $report->{body} = Ukigumo::Server::Command::Report->find( report_id => $report->{report_id} )->{body};
    }
    my $res = $c->render(
        'rss.xml.tx' => {
            reports   => $reports,
            now       => time(),
            base_uri  => $c->req->base,
        }
    );
    $res->content_type( 'application/xml' );
    $res;
};

get '/recent' => sub {
    my ($c, $args) = @_;

    my $page = $c->req->param('page') || 1;
    my $limit = 50;

    my ($reports, $pager) = Ukigumo::Server::Command::Report->recent_list(
        page      => $page,
        limit     => $limit,
    );
    return $c->render(
        'recent.tx' => {
            reports   => $reports,
            pager     => $pager,
            now       => time(),
        }
    );
};

get '/failure' => sub {
    my ($c, $args) = @_;

    my $project_src = Ukigumo::Server::Command::Branch->list(
        status => [2, 3],
    );
    my %projects = ();
    for my $project (@$project_src) {
        push @{$projects{$project->{project}}}, $project;
    }

    return $c->render(
        'index.tx' => {
            projects => \%projects,
            now      => time(),
        }
    );
};

get '/all_failure' => sub {
    my ($c, $args) = @_;

    my $page = $c->req->param('page') || 1;
    my $limit = 50;

    my ($reports, $pager) = Ukigumo::Server::Command::Report->failure_list(
        page      => $page,
        limit     => $limit,
    );

    return $c->render(
        'recent.tx' => {
            reports   => $reports,
            pager     => $pager,
            now       => time(),
        }
    );
};

get '/project/{project}' => sub {
    my ($c, $args) = @_;

    my $project = $args->{project} || die;
    my $project_src = Ukigumo::Server::Command::Branch->list(
       project => $project,
    );

    $c->render(
        'project/index.tx',
        {
            now          => time(),
            project_name => $project,
            projects     => $project_src,
        }
    );
};

get '/project/{project}/{branch:[A-Za-z0-9/_\-\.]+}' => sub {
    my ($c, $args) = @_;
    my $project = $args->{project};
    my $branch = $args->{branch};
    my $page = $c->req->param('page') || 1;
    my $limit = 50;

    my $branch_id = Ukigumo::Server::Command::Branch->find(
        project => $args->{project},
        branch  => $args->{branch},
    );
    return $c->res_404() unless $branch_id;

    my ($reports, $pager) = Ukigumo::Server::Command::Report->list(
        branch_id => $branch_id,
        page      => $page,
        limit     => $limit,
    );
    my $reports_json = encode_json($reports);

    return $c->render(
        'report_list.tx' => {
            project      => $project,
            branch       => $branch,
            branch_id    => $branch_id,
            reports      => $reports,
            reports_json => mark_raw("$reports_json"),
            pager        => $pager,
            now          => time(),
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
        'branch_delete.tx' => {
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
            'show_report.tx',
            {
                report => $report,
                body => Ukigumo::Server::Util::make_line_link( $report->{body} )
            }
        );
    } else {
        return $c->res_404();
    }
};

get '/docs/api' => sub {
    my ($c) = @_;
    return $c->render('docs/api.tx');
};

get '/docs/{path:[a-z0-9_-]+}' => sub {
    my ($c, $args) = @_;
    my $path = $args->{path} // die;
    require Ukigumo::Server::Command::Docs;
    my $html = Ukigumo::Server::Command::Docs->render($path);

    $c->render('docs.tx', {
        doc => $html
    });
};

1;
