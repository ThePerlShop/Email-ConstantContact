package t::lib::Email::ConstantContact::TestHttpRequest;
use strict;
use warnings;

use parent 'Exporter';

our @EXPORT = qw(cmp_http_requests);


use Test::Deep;


=head1 NAME

t::lib::Email::ConstantContact::TestHttpRequest - Test functions to test for
C<HTTP::Request> objects used by C<Email::ConstantContact> unit tests.

=head1 SYNOPSIS

    use t::lib::Email::ConstantContact::TestHttpRequest;

    cmp_http_requests(
        $requests,
        [
            'http://company.com/request/1',
            'http://company.com/request/2',
        ],
        'description of test',
    );

=cut


# Function: return a Test::Deep comparator tree for an HTTP GET request for a given URI.
sub _http_request_cmp {
    my $uri = shift;
    return all(
        isa('HTTP::Request'),
        methods(
            method => 'GET',
            uri => methods(
                as_string => $uri,
            ),
            [ header => 'authorization' ] => 'Basic YXBpa2V5JXVzZXJuYW1lOnBhc3N3b3Jk',
        ),
    );
};


sub cmp_http_requests {
    my ($got, $expected, $description) = @_;

    local $Test::Builder::Level = $Test::Builder::Level + 1;

    $expected = [ map {
        # if a reference, then assume a fully-formed comparator
        # if a scalar, then assume it's a URI
        ref $_ ? $_ : _http_request_cmp($_)
    } @$expected ] if ref $expected eq 'ARRAY';

    cmp_deeply(
        $got,
        $expected,
        $description,
    );
}


1;
