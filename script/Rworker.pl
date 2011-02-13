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
my $R_dir = $root_dir . '/R';
my $restarter = 0;

GetOptions(
    'c|config=s' => \$config_file,
    'd|dir=s' => \$R_dir,
);

die 'config not found' unless $config_file;
die 'R dir not found' unless $R_dir;

my $rworker = Rworker::Worker->new({
    config_file => $config_file,
    R_dir => $R_dir,
});
$rworker->run;

