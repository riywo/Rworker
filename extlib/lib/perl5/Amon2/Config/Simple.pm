package Amon2::Config::Simple;
use strict;
use warnings;
use File::Spec;

sub load {
    my ($class, $c) = (shift, shift);
    my %conf = @_ == 1 ? %{$_[0]} : @_;

    my $env = $conf{environment} || $c->mode_name || 'development';
    my $fname = File::Spec->catfile($c->base_dir, 'config', "${env}.pl");
    my $config = do $fname or die "Cannot load configuration file: $fname";
    return $config;
}

1;
__END__

=encoding utf-8

=head1 NAME

Amon2::Config::Simple - Default configuration file loader

=head1 SYNOPSIS

    package MyApp;
    # do "config/@{{ $c->mode_name ]}.pl"
    use Amon2::Config::Simple;
    sub load_config { Amon2::Config::Simple->load(shift) }

=head1 DESCRIPTION

This is a default configuration file loader for L<Amon2>.

This module loads the configuration by C<< do >> function. Yes, it's just plain perl code structure.

=head1 HOW DO YOU USE YOUR OWN ENVIRONMENT VARIABLE FOR DETECTING CONFIGURATION FILE?

If you want to use "config/$ENV{RUN_MODE}.pl" for the configuration file, you can write code as following:

    package MyApp;
    use Amon2::Config::Simple;
    sub load_config { Amon2::Config::Simple->load(shift, +{ environment => $ENV{RUN_MODE} } ) }
