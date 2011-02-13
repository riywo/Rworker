#!/usr/bin/env perl
use strict;
use warnings;

use FindBin;
use Gearman::Client;
use JSON;

my $dir = "$FindBin::RealBin/../../R";
my $data = {
    r_file    => "sample.r",
    r_return  => "sample.log",
    data_file => "$dir/data/cars.csv",
    img_file  => "$dir/img/sample.png",
};

my $args = encode_json($data);

my $client = Gearman::Client->new;
$client->job_servers('127.0.0.1');

my $ret = $client->do_task('Rworker', $args);
#my $ret = $client->dispatch_background('Rworker', $args);

