#!/usr/bin/env perl
use strict;
use warnings;

use FindBin;
use Gearman::Client;
use JSON;

my $dir = "$FindBin::RealBin/../../R";
my $arg1 = encode_json({
    r_file    => "$dir/r_file/sample.r",
    r_return  => "$dir/r_return/sample.log",

    data => "$dir/data/cars.csv",
    img  => "$dir/img/sample.png",
});
my $arg2 = encode_json({
    r_file    => "https://gist.github.com/raw/829619/3cf65e97afe00c7fc0a1ebb1a9fb48c7c9ae3653/sample.r",
    r_return  => "http://localhost:5000/api/job/1/log?log=",
#    r_file    => "$dir/r_file/sample.r",
#    r_return  => "$dir/r_return/test.log",

    data => "https://gist.github.com/raw/829631/ed027079cc5c1557fd4a6fefd4afc81e31cc384a/cars.csv",
    img  => "/tmp/sample.png",

    upload_uri => "http://localhost:5000/api/job/1/upload",
    upload_key => "img",
});

print "$arg1\n";
print "$arg2\n";

my $client = Gearman::Client->new;
$client->job_servers('127.0.0.1');

$client->do_task('Rworker', $arg1);
$client->do_task('Rworker', $arg2);

#$client->dispatch_background('Rworker', $args1);
#$client->dispatch_background('Rworker', $args2);

