#!/usr/bin/env perl
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";
use lib "$FindBin::Bin/../extlib/lib/perl5";

use Rworker::Worker;
use Getopt::Long;

my $root_dir = "$FindBin::Bin/..";
my $config_file = $root_dir . '/config/rworker.pl';
#my $restarter = 0;

GetOptions(
    'c|config=s' => \$config_file,
    'd|dir=s' => \$root_dir,
);

die 'config not found' unless $config_file;
die 'root dir not found' unless $root_dir;

my $rworker = Rworker::Worker->new({
    config_file => $config_file,
    root_dir => $root_dir,
});
$rworker->run;

