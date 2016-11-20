#!/usr/bin/env perl
use strict;
use warnings;

t::lib::Email::ConstantContact::new->runtests;


BEGIN {
package t::lib::Email::ConstantContact::new;
use strict;
use warnings;

use parent 'Test::Class';

use Test::Most;
use Data::Dumper;

# load code to be tested
use Email::ConstantContact;


=head1 NAME

t::lib::Email::ConstantContact::new - Unit test the C<< Email::ConstantContact->new() >> method.

=head1 SYNOPSIS

    # run all tests  
    prove -lv t/lib/Email/ConstantContact/00-new.t

    # run single test method
    TEST_METHOD=test_METHOD_NAME prove -lv t/lib/Email/ConstantContact/00-new.t

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

=head2 test_legacy

Test legacy constructor calling convention C<new($apikey, $username, $password)>.
Instantiate the class and confirm that the object was created as expected.

=cut

sub test_legacy : Test(1) {
    my $test = shift;

    # Set Data::Dumper format for diag statements below.
    local $Data::Dumper::Sortkeys = 1;
    local $Data::Dumper::Indent = 1;
    local $Data::Dumper::Useqq = 1;

    # Test data for instantiation.
    my $apikey = 'ABCDEFG1234567';
    my $username = 'me&company';
    my $username_url_encoded = 'me%26company';
    my $password = 'topsecret!@#$%12345';

    # Call code under test: construct new instance.
    my $cc = Email::ConstantContact->new($apikey, $username, $password);

    # Validate object.
    cmp_deeply(
        $cc,
        all(
            isa('Email::ConstantContact'),
            noclass({
                apikey => $apikey,
                username => $username,
                password => $password,
                cchome => 'https://api.constantcontact.com',
                rooturl => "https://api.constantcontact.com/ws/customers/$username_url_encoded",
            }),
        ),
        "instance constructed with expected data",
    ) or diag(Data::Dumper->Dump([$cc], ['cc']));
}


=head2 test_named

Test the named-parameter constructor calling convention
C<< new(apikey => $apikey, username => $username, password => $password) >>.
Instantiate the class and confirm that the object was created as expected.

=cut

sub test_named : Test(1) {
    my $test = shift;

    # Set Data::Dumper format for diag statements below.
    local $Data::Dumper::Sortkeys = 1;
    local $Data::Dumper::Indent = 1;
    local $Data::Dumper::Useqq = 1;

    # Test data for instantiation.
    my $apikey = 'ABCDEFG1234567';
    my $username = 'me&company';
    my $username_url_encoded = 'me%26company';
    my $password = 'topsecret!@#$%12345';

    # Call code under test: construct new instance.
    my $cc = Email::ConstantContact
        ->new(apikey => $apikey, username => $username, password => $password);

    # Validate object.
    cmp_deeply(
        $cc,
        all(
            isa('Email::ConstantContact'),
            noclass({
                apikey => $apikey,
                username => $username,
                password => $password,
                cchome => 'https://api.constantcontact.com',
                rooturl => "https://api.constantcontact.com/ws/customers/$username_url_encoded",
            }),
        ),
        "instance constructed with expected data",
    ) or diag(Data::Dumper->Dump([$cc], ['cc']));
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
    my $username = 'me&company';
    my $username_url_encoded = 'me%26company';
    my $access_token = '5754b85f-a27e-47fa-b248-e91eb8cead35';

    # Call code under test: construct new instance.
    my $cc = Email::ConstantContact
        ->new(username => $username, access_token => $access_token);

    # Validate object.
    cmp_deeply(
        $cc,
        all(
            isa('Email::ConstantContact'),
            noclass({
                username => $username,
                access_token => $access_token,
                cchome => 'https://api.constantcontact.com',
                rooturl => "https://api.constantcontact.com/ws/customers/$username_url_encoded",
            }),
        ),
        "instance constructed with expected data",
    ) or diag(Data::Dumper->Dump([$cc], ['cc']));
}


1;

} # BEGIN
