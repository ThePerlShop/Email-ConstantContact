#!/usr/bin/env perl
use strict;
use warnings;

t::lib::Email::ConstantContact::_new_request->runtests;


BEGIN {
package t::lib::Email::ConstantContact::_new_request;
use strict;
use warnings;

use parent 'Test::Class';

use Test::Most;
use Data::Dumper;


use t::lib::Email::ConstantContact::TestHttpRequest qw(cmp_http_request);


# load code to be tested
use Email::ConstantContact;


=head1 NAME

t::lib::Email::ConstantContact::_new_request - Unit test the C<< Email::ConstantContact->_new_request() >> method.

=head1 SYNOPSIS

    # run all tests  
    prove -lv t/lib/Email/ConstantContact/_new_request.t

    # run single test method
    TEST_METHOD=test_METHOD_NAME prove -lv t/lib/Email/ConstantContact/_new_request.t

=cut


## Test::Class boilerplate.

{
    # signal to Test::Class not to implicitly skip tests
    my $fail_if_returned_early = 1;
    sub fail_if_returned_early { $fail_if_returned_early }

    # return bailout($reason);
    # ...or...
    # bailout && return $reason;
    sub bailout {
        my ($reason) = @_;
        $fail_if_returned_early = 0;
        return $reason // 1;
    }

    # reset $fail_if_returned_early before each test method runs
    sub no_bailout : Test(setup) {
        $fail_if_returned_early = 1;
    }
}


## Tests

=head1 TESTS

=head2 test_password

Call C<_new_request($request)> on an instance configured to use
username/password authentication. Verify the returned request, including
authorization header.

=cut

sub test_password : Test(1) {
    my $test = shift;

    # Set Data::Dumper format for diag statements below.
    local $Data::Dumper::Sortkeys = 1;
    local $Data::Dumper::Indent = 1;
    local $Data::Dumper::Useqq = 1;

    # Instantiate CC object.
    my $cc = Email::ConstantContact
        ->new(apikey => 'apikey', username => 'username', password => 'password');

    # Call code under test.
    # (The code under test should lowercase capital letters convert http to https.)
    my $request = $cc->_new_request(GET => 'http://API.ConstantContact.com/ws/customers/username/area/id');

    # Validate request.
    cmp_http_request(
        $request,
        'https://api.constantcontact.com/ws/customers/username/area/id',
        "constructed request",
    ) or diag(Data::Dumper->Dump([$request], ['request']));
}


=head2 test_access_token

Test the access-token constructor calling convention
C<< new(username => $username, access_token => $access_token) >>.
Instantiate the class and confirm that the object was created as expected.

=cut

sub test_access_token : Test(1) {
    my $test = shift;

    # Set Data::Dumper format for diag statements below.
    local $Data::Dumper::Sortkeys = 1;
    local $Data::Dumper::Indent = 1;
    local $Data::Dumper::Useqq = 1;

    # Test data for instantiation.
    my $access_token = '5754b85f-a27e-47fa-b248-e91eb8cead35';

    # Instantiate CC object.
    my $cc = Email::ConstantContact
        ->new(username => 'username', access_token => $access_token);

    # Call code under test.
    # (The code under test should lowercase capital letters convert http to https.)
    my $request = $cc->_new_request(GET => 'http://API.ConstantContact.com/ws/customers/username/area/id');

    # Validate request.
    cmp_http_request(
        $request,
        {
            authorization => "Bearer $access_token",
            url => 'https://api.constantcontact.com/ws/customers/username/area/id',
        },
        "constructed request",
    ) or diag(Data::Dumper->Dump([$request], ['request']));
}


1;

} # BEGIN
