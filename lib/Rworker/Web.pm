package Rworker::Web;
use strict;
use warnings;
use parent qw/Rworker Amon2::Web/;

# load all controller classes
use Module::Find ();
Module::Find::useall("Rworker::Web::C");

# custom classes
use Rworker::Web::Request;
use Rworker::Web::Response;
sub create_request  { Rworker::Web::Request->new($_[1]) }
sub create_response { shift; Rworker::Web::Response->new(@_) }

# dispatcher
use Rworker::Web::Dispatcher;
sub dispatch {
    return Rworker::Web::Dispatcher->dispatch($_[0]) or die "response is not generated";
}

# setup view class
use Tiffany::Text::Xslate;
{
    my $view_conf = __PACKAGE__->config->{'Text::Xslate'} || die "missing configuration for Text::Xslate";
    my $view = Tiffany::Text::Xslate->new(+{
        'syntax'   => 'TTerse',
        'module'   => [ 'Text::Xslate::Bridge::TT2Like' ],
        'function' => {
            c => sub { Amon2->context() },
            uri_with => sub { Amon2->context()->req->uri_with(@_) },
            uri_for  => sub { Amon2->context()->uri_for(@_) },
        },
        %$view_conf
    });
    sub create_view { $view }
}

# load plugins
# __PACKAGE__->load_plugins('Web::FillInFormLite');
# __PACKAGE__->load_plugins('Web::NoCache');

# for your security
__PACKAGE__->add_trigger(
    AFTER_DISPATCH => sub {
        my ( $c, $res ) = @_;
        $res->header( 'X-Content-Type-Options' => 'nosniff' );
    },
);

1;
