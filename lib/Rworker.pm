package Rworker;
use strict;
use warnings;
use parent qw/Amon2/;
our $VERSION='0.01';

use Amon2::Config::Simple;
sub load_config { Amon2::Config::Simple->load(shift) }


use Rworker::DB;

sub db {
    my ($self) = @_;
    if (!defined $self->{db}) {
        my $conf = $self->config->{'DBIx::Skinny'} or die "missing configuration for 'DBIx::Skinny'";
        $self->{db} = Rworker::DB->new($conf);
    }
    return $self->{db};
}


1;
