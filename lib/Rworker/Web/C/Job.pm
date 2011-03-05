package Rworker::Web::C::Job;
use strict;
use warnings;
use URI::Escape;
use Gearman::Client;
use JSON;
use File::Copy;
use File::Spec;
use Encode;

use Data::Dumper;

sub index {
    my ($class, $c) = @_;




    $c->render("job/index.tt");
}

sub add {
    my ($class, $c) = @_;

    my $row = $c->db->insert(job => {
        r_file   => $c->req->param('r_file'),
        r_return => $c->req->param('r_return'),
    });

    my $args;
    my $job_id = $row->get_column('job_id'); 
    my $r_return = $row->get_column('r_return');
    $r_return =~ s/{job_id}/$job_id/;
    $row->update({ r_return => $r_return });
    $args->{'r_file'} = $row->get_column('r_file');
    $args->{'r_return'} = $row->get_column('r_return');

    for my $i (1..4) {
        my $value = $c->req->param("value$i");
        $value =~ s/{job_id}/$job_id/g;
        $c->db->fast_insert(job_args =>{
            job_id => $job_id,
            arg => $c->req->param("arg$i"),
            value => $value,
        });
        $args->{$c->req->param("arg$i")} = $value;
    }

    $c->db->fast_insert(job_return =>{
        job_id => $job_id,
        log => '',
    });

    my $client = Gearman::Client->new;
    $client->job_servers('127.0.0.1');
    $client->dispatch_background('Rworker', encode_json($args));

    $c->redirect("/job/$job_id");
}

sub show_job {
    my ($class, $c) = @_;
    my $job_id = $c->{args}->{job_id};

    my $r_file = $c->db->single(job => {job_id => $job_id})->get_column('r_file');
    my $itr = $c->db->search(job_args => {job_id => $job_id});
    my $args;
    while ( my $row = $itr->next) {
        push @{$args}, {
            arg => $row->get_column('arg'),
            value => $row->get_column('value'),
        };
    }
    my $log = $c->db->single(job_return => {job_id => $job_id})->get_column('log');
    $itr = $c->db->search(job_upload => {job_id => $job_id});
    my $uploads;
    while ( my $row = $itr->next) {
        push @{$uploads}, {
            type => $row->get_column('type'),
            path => $row->get_column('path'),
        };
    }

    $c->render("job/show_job.tt", {
        job_id => $job_id,
        r_file => $r_file,
        args => $args,
        log => $log,
        uploads => $uploads,
    });
}

sub polling {
    my ($class, $c) = @_;
    my $job_id = $c->{args}->{job_id};

    my $log = $c->db->single(job_return => {job_id => $job_id})->get_column('log');
    my $data = {
        log => $log,
    };

    if ($log =~ /Rworker::Finish$/) {
        $data->{'success'} = 1;
        my $itr = $c->db->search(job_upload => {job_id => $job_id});
        while ( my $row = $itr->next ) {
            push @{$data->{'uploads'}}, {
                type => $row->get_column('type'),
                path => $row->get_column('path'),
            };
        }
    }

    my $txt = encode_json($data);
    return $c->create_response(
        200,
        [
            'Content-Type'   => 'text/plain; charset=utf-8',
            'Content-Length' => length($txt)
        ],
        [$txt]
    );
}

sub upload {
    my ($class, $c) = @_;
    my $job_id = $c->{args}->{job_id};
    my $uploads = $c->req->uploads;
    my $comment = $c->req->param('comment');

    my $upload_dir = File::Spec->catfile($c->base_dir, 'htdocs', 'static', 'upload');
    for my $key (keys %{$uploads}) {
        my $file_path = "$job_id-" . $uploads->{$key}->filename;
        move($uploads->{$key}->tempname, "$upload_dir/$file_path");
        $c->db->insert(job_upload => {
            job_id => $job_id,
            type => $key,
            path => $file_path,
        });
    }

    my $txt = "OK";
    return $c->create_response(
        200,
        [
            'Content-Type'   => 'text/plain; charset=utf-8',
            'Content-Length' => length($txt)
        ],
        [$txt]
    );
}

sub log {
    my ($class, $c) = @_;
    my $job_id = $c->{args}->{job_id};
    my $new_log = encode('utf-8', uri_unescape($c->req->param('log')));
    my $row = $c->db->single(job_return => { job_id => $job_id });

    my $prev_log = encode('utf-8', $row->get_column('log'));
    my $log = $prev_log ? "$prev_log\n$new_log" : "$new_log";
    $row->update({ log => $log });

    my $txt = "OK";
    return $c->create_response(
        200,
        [
            'Content-Type'   => 'text/plain; charset=utf-8',
            'Content-Length' => length($txt)
        ],
        [$txt]
    );
}

1;
