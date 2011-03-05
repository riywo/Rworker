package Rworker::Web::C::Root;
use strict;
use warnings;
use Data::Dumper;
use URI::Escape;

sub index {
    my ($class, $c) = @_;
    $c->render("index.tt");
}

sub test_log {
    my ($class, $c) = @_;

    my $data = uri_unescape($c->req->param('data'));
print "$data\n";

    my $txt = "";
    return $c->create_response(
        200,
        [
            'Content-Type'   => 'text/plain; charset=utf-8',
            'Content-Length' => length($txt)
        ],
        [$txt]
    );
}















sub upload {
    my ($self, $c) = @_;

    print Dumper $c->req->uploads;
    my $res = $c->render_json({ file => $c->req->uploads->{file}->filename });
    $res->content_type('text/html');
    $res;
}

sub queue_test {
    my ($self, $c) = @_;
    $c->render(
        'queue-test.tt' => {
            finish => -f "/tmp/hoge" ? 1 : undef
        }
    );
}


sub api {
    my ($self, $c) = @_;
sleep 3;
    my $res = $c->render_json({ 'return' => 'hoge' });
    $res->content_type('text/html');
    $res;
}

sub polling {
    my ($self, $c) = @_;
    my $json = { log => "still running..." };
    $json = { success => 1 } if(-f "/tmp/hoge");
    my $res = $c->render_json($json);
    $res->content_type('text/html');
    $res;
}

1;
