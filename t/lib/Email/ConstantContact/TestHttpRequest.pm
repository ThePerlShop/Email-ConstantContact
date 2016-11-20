package t::lib::Email::ConstantContact::TestHttpRequest;
use strict;
use warnings;

use parent 'Exporter';

our @EXPORT = qw(cmp_http_request cmp_http_requests);


use Test::Deep;


=head1 NAME

t::lib::Email::ConstantContact::TestHttpRequest - Test functions to test for
C<HTTP::Request> objects used by C<Email::ConstantContact> unit tests.

=head1 SYNOPSIS

    use t::lib::Email::ConstantContact::TestHttpRequest;

    cmp_http_request(
        $request,
        'http://company.com/request/1',
        'description of test',
    );

    cmp_http_request(
        $request,
        {
            authorization => 'Basic YXBpa2V5JXVzZXJuYW1lOnBhc3N3b3Jk',
            url => 'http://company.com/request/1',
        },
        'description of test',
    );


    cmp_http_requests(
        $requests,
        [
            'http://company.com/request/1',
            'http://company.com/request/2',
        ],
        'description of test',
    );

    cmp_http_requests(
        $requests,
        {
            authorization => 'Basic YXBpa2V5JXVzZXJuYW1lOnBhc3N3b3Jk',
            urls => [
                'http://company.com/request/1',
                'http://company.com/request/2',
            ],
        },
        'description of test',
    );

=cut


# Return a Test::Deep comparator tree for an HTTP GET request for a given URI.
sub _http_request_cmp {
    my ($authorization, $uri) = @_;

    return all(
        isa('HTTP::Request'),
        methods(
            method => 'GET',
            uri => methods(
                as_string => $uri,
            ),
            [ header => 'authorization' ] => $authorization,
        ),
    );
};


sub cmp_http_request {
    my ($got, $expected, $description) = @_;

    local $Test::Builder::Level = $Test::Builder::Level + 1;

    # Rewrite $expected to standard form if only a URL is passed in.
    $expected = {
        url => $expected,
    } unless ref $expected;

    my $authorization = $expected->{authorization}
        // 'Basic YXBpa2V5JXVzZXJuYW1lOnBhc3N3b3Jk';

    my $expected_request = _http_request_cmp($authorization, $expected->{url});

    cmp_deeply(
        $got,
        $expected_request,
        $description,
    );
}


sub cmp_http_requests {
    my ($got, $expected, $description) = @_;

    local $Test::Builder::Level = $Test::Builder::Level + 1;

    # Rewrite $expected to standard form if only an array of URLs is passed in.
    $expected = {
        urls => $expected,
    } if ref $expected eq 'ARRAY';

    my $authorization = $expected->{authorization}
        // 'Basic YXBpa2V5JXVzZXJuYW1lOnBhc3N3b3Jk';

    my $expected_requests = [ map {
        _http_request_cmp($authorization, $_)
    } @{ $expected->{urls} } ];

    cmp_deeply(
        $got,
        $expected_requests,
        $description,
    );
}


1;
