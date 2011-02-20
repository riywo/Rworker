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
        my $conf = $self->config->{'Teng'} or die "missing configuration for 'Teng'";
        my $dbh = DBI->connect($conf->{dsn}, $conf->{username}, $conf->{password}, $conf->{connect_options}) or die "Cannot connect to DB:: " . $DBI::errstr;
        $self->{db} = Rworker::DB->new({ dbh => $dbh });
    }
    return $self->{db};
}


1;
