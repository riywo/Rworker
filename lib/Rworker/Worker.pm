package Rworker::Worker;
use strict;
use warnings;

use base qw/Class::Accessor::Fast/;
use Parallel::Prefork;
use Gearman::Worker;
use JSON;
use URI::Escape;
use File::Temp qw(tempfile);
use Furl;
use HTTP::Request::Common;
use POSIX;

use Data::Dumper;

__PACKAGE__->mk_accessors(qw/config_file root_dir/);

sub run {
    my $self = shift;
    my $pm = Parallel::Prefork->new(
        max_workers => 10,
        trap_signals => {
                TERM => 'TERM',
                HUP  => 'TERM',
        },
    );

    my $config = $self->load_config();
    while ($pm->signal_received ne 'TERM') {

        if ($pm->signal_received eq 'HUP') {
                $config = load_config();
        }
        $pm->start and next;

        $self->run_worker($config);

        $pm->finish;
    }

    $pm->wait_all_children();
}

sub load_config {
    my $self = shift;
    my $file = $self->config_file;
    my $config = do $file or die "Error load config file $self->config_file";
    $config->{'r_file_dir'} = $self->root_dir."/R/".$config->{'r_file_dir'} if($config->{'r_file_dir'} !~ /^\//);
    $config->{'r_return_dir'} = $self->root_dir."/R/".$config->{'r_return_dir'} if($config->{'r_return_dir'} !~ /^\//);
    $config->{'temp_dir'} = $self->root_dir."/".$config->{'temp_dir'} if($config->{'temp_dir'} !~ /^\//);
    print Dumper $config;
    print "load config\n";
    return $config;
}

sub run_worker {
    my ($self, $config) = @_;

    my $worker = Gearman::Worker->new();
    $worker->job_servers($config->{'job_servers'});
    $worker->register_function( 'Rworker' => sub {
        my $job = shift;
        my $ret = $self->worker_job($config, $job->arg);
        return $ret;
    });

    my $got_term;
    local $SIG{TERM} = sub { $got_term++ };
    $worker->work(stop_if => sub { $got_term }) until $got_term;
}

sub worker_job {
    my ($self, $config, $arg) = @_;
    $self->{'config'} = $config;
    my $args = decode_json($arg);
    my $r_file = $args->{'r_file'}; delete $args->{'r_file'};
    my $r_return = $args->{'r_return'}; delete $args->{'r_return'};
    $self->{'pid'} = $$;
    my $fifo = "$self->{'config'}->{'temp_dir'}/$self->{'pid'}.fifo";
    mkfifo($fifo, 0600);
    $self->{'fifo'} = $fifo;
    $args->{'fifo'} = $fifo;
    my $json = encode_json($args);

    if ($r_file =~ /^(http|https):\/\//) {
        my ($fh, $file) = tempfile("$self->{'pid'}_XXXX", SUFFIX => '.r', DIR => $self->{'config'}->{'temp_dir'});
        $self->{'temp_file'} = $file;
        my $furl = Furl->new();
        my $res = $furl->request(
            method => 'GET',
            url => $r_file,
            write_file => $fh,
        );
        close $fh;
        $r_file = $file;
    }

    my $CMD = "$config->{'R'} -f $r_file --args '$json'";
    print "start  $CMD\n";
    open IN, "cd $config->{'r_file_dir'}; $CMD 2>&1 |";
    my $oldfh = select IN; $| = 1; select $oldfh;

    if ($r_return !~ /^(http|https):\/\//) {
        open OUT, ">$r_return";
        $oldfh = select OUT; $| = 1; select $oldfh;
    }
    while (my $line = <IN>) {
        chomp $line;
        if ($line =~ /^Rworker::([^ ]+) (.*)$/) {
            my ($method, $data) = ($1, $2);
            $self->rworker_func($method, $data);
        }

        if ($r_return =~ /^(http|https):\/\//) {
            my $escaped = uri_escape($line);
            my $furl = Furl->new();
            my $res = $furl->get("$r_return$escaped");
        }else{
            print OUT "$line\n";
        }
    }
    close OUT if($r_return !~ /^(http|https):\/\//);
    close IN;

    unlink $fifo;
    if ($self->{'temp_file'}) {
        unlink $self->{'temp_file'};
        delete $self->{'temp_file'};
    }
    if ($self->{'unlink'}){
        for my $file (@{$self->{'unlink'}}) {
            unlink $file;
        }
    }

    print "finish $CMD\n";
}

sub rworker_func {
    my ($self, $method, $data) = @_;
    if ($method eq 'Download') {
        $self->rworker_download($data);
    }elsif ($method eq 'Upload') {
        $self->rworker_upload($data);
    }
}

sub rworker_download {
    my ($self, $data) = @_;
    my $args = decode_json($data);

    my $furl = Furl->new();
    my ($fh, $file) = tempfile("$self->{'pid'}_download_XXXXXXXX", DIR => $self->{'config'}->{'temp_dir'});
    push @{$self->{'unlink'}}, $file;
    my $res = $furl->request(
        method => 'GET',
        url => $args->{'uri'},
        write_file => $fh,
    );
    close $fh;

    $self->write_message({file => $file});
}

sub rworker_upload {
    my ($self, $data) = @_;
    my $args = decode_json($data);

    my $req = POST(
        $args->{'uri'},
        Content_Type => 'form-data',
        Content => {
            $args->{'key'} => [$args->{'file'}],
        },
    );
    my $furl = Furl->new;
    my $res = $furl->request($req);

    $self->write_message({status => $res->status});
}

sub write_message {
    my ($self, $data) = @_;
    open  FIFO, "> $self->{'fifo'}";
    print FIFO encode_json($data)."\n";
    close FIFO;
}

1;
