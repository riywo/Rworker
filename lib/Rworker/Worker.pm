package Rworker::Worker;
use strict;
use warnings;

use base qw/Class::Accessor::Fast/;
use Parallel::Prefork;
use Gearman::Worker;
use JSON;
use Data::Dumper;
__PACKAGE__->mk_accessors(qw/config_file R_dir/);

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
    $config->{'r_file_dir'} = $self->R_dir."/".$config->{'r_file_dir'} if($config->{'r_file_dir'} !~ /^\//);
    $config->{'r_return_dir'} = $self->R_dir."/".$config->{'r_return_dir'} if($config->{'r_return_dir'} !~ /^\//);
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
    $worker->work(stop_if => sub { $got_term })
    until $got_term;
}

sub worker_job {
    my ($self, $config, $arg) = @_;
    my $args = decode_json($arg);
    my $r_file = $args->{'r_file'}; delete $args->{'r_file'};
    my $r_return = $config->{'r_return_dir'}."/".$args->{'r_return'}; delete $args->{'r_return'};
    my $json = encode_json($args);

    print "start  $config->{'R'} $r_file --args '$json'\n";
    my @ret = `cd $config->{'r_file_dir'}; $config->{'R'} -f $r_file --args '$json' 2>&1`;
    print "finish $config->{'R'} $r_file --args '$json'\n";

    open  OUT, ">$r_return";
    for my $line (@ret) {
        print OUT $line;
    }
    close OUT;
}

1;
