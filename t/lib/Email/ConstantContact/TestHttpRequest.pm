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

    cmp_http_requests(
        $requests,
        [
            {
                method => 'POST',
                authorization => 'Basic YXBpa2V5JXVzZXJuYW1lOnBhc3N3b3Jk',
                url => 'http://company.com/request',
                content => $content,
            },
            {
                method => 'GET',
                authorization => 'Basic YXBpa2V5JXVzZXJuYW1lOnBhc3N3b3Jk',
                url => 'http://company.com/request/1',
            },
        },
        'description of test',
    );

=cut


# Return a Test::Deep comparator tree for an HTTP GET request for a given URI.
sub _http_request_cmp {
    my ($expected) = @_;

    return all(
        isa('HTTP::Request'),
        methods(
            method => $expected->{method} // 'GET',
            uri => methods(
                as_string => $expected->{url},
            ),
            [ header => 'authorization' ] =>
                $expected->{authorization} // 'Basic YXBpa2V5JXVzZXJuYW1lOnBhc3N3b3Jk',
            ( content => $expected->{content} ) x!! defined $expected->{content},
        ),
    );
};


sub cmp_http_request {
    my ($got, $expected, $description) = @_;

    local $Test::Builder::Level = $Test::Builder::Level + 1;

    # Rewrite $expected to hashref form if only a URL is passed in.
    $expected = {
        url => $expected,
    } unless ref $expected;

    my $expected_request = _http_request_cmp($expected);

    cmp_deeply(
        $got,
        $expected_request,
        $description,
    );
}


sub cmp_http_requests {
    my ($got, $expected, $description) = @_;

    local $Test::Builder::Level = $Test::Builder::Level + 1;

    # Rewrite $expected to arrayref form if a hashref is passed in.
    if ( ref $expected eq 'HASH' ) {
        my $expected_template = $expected;
        my $urls = delete $expected_template->{urls};
        $expected = [ map { %$expected_template, url => $_ } @$urls ];
    }

    # Rewrite array elements to hashrefs if only a URL is passed in them.
    $expected = [ map { ref $_ ? $_ : { url => $_ } } @$expected ];

    my $expected_requests = [ map { _http_request_cmp($_) } @{ $expected } ];

    cmp_deeply(
        $got,
        $expected_requests,
        $description,
    );
}


1;
