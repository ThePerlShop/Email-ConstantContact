#!/usr/bin/env perl
use strict;
use warnings;

t::lib::Email::ConstantContact::Contact::save->runtests;


BEGIN {
package t::lib::Email::ConstantContact::Contact::save;
use strict;
use warnings;

use parent 'Test::Class';

use Test::Most;
use Data::Dumper;


use t::lib::Email::ConstantContact::MockUserAgent;
use t::lib::Email::ConstantContact::TestHttpRequest qw(cmp_http_requests);
use t::lib::Email::ConstantContact::TestDeepXML qw(xml);


# load code to be tested
use Email::ConstantContact;


=head1 NAME

t::lib::Email::ConstantContact::Contact::save - Unit test the C<< Email::ConstantContact::Contact->save() >> method.

=head1 SYNOPSIS

    # run all tests  
    prove -lv t/lib/Email/ConstantContact/Contact/save.t

    # run single test method
    TEST_METHOD=test_METHOD_NAME prove -lv t/lib/Email/ConstantContact/Contact/save.t

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


## Private functions/methods

# Return ( key => value ) of contact data for the contact above.
sub _contact_data {
    return (
        id => 'http://api.constantcontact.com/ws/customers/username/contacts/1',
        Name => 'John Doe',
        FirstName => 'John',
        LastName => 'Doe',
        CompanyName => 'Acme Corp',
        WorkPhone => '555-555-1234',
        Addr1 => '123 Any St',
        StateCode => 'MA',
        StateName => 'Massachusetts',
        PostalCode => '01234',
        EmailAddress => 'jdoe@acme.company.com',
    );
}

# Return a Test::Deep comparator tree for the contact above.
sub _contact_cmp {
    my ($cc) = @_;
    return all(
        isa('Email::ConstantContact::Contact'),
        noclass(superhashof({
            _cc => shallow($cc),
            _contact_data,
        })),
    );
}


## Startup/shutdown/setup/teardown methods

# Setup mock overrides for module functions.
sub _mock_modules : Test(setup) {
    my $test = shift;

    $test->{ua_module} = t::lib::Email::ConstantContact::MockUserAgent->new();
    $test->{ua_module}->clear_requests();
}

# Cleanup mock overrides.
sub _unmock_modules : Test(teardown) {
    my $test = shift;

    delete $test->{ua_module};
}


## Tests

=head1 TESTS

=head2 test_smoke

Test calling save().

=cut

sub test_smoke : Test(3) {
    my $test = shift;

    # Set Data::Dumper format for diag statements below.
    local $Data::Dumper::Sortkeys = 1;
    local $Data::Dumper::Indent = 1;
    local $Data::Dumper::Useqq = 1;

    # Set HTTP code to be returned from mock HTTP request.
    $test->{ua_module}->response_code( 200 );

    # Contact data for testing.
    my %contact_data = _contact_data;

    # Instantiate CC object.
    my $cc = Email::ConstantContact->new('apikey', 'username', 'password');

    # Instantiate and initialize Contact object.
    my $contact = Email::ConstantContact::Contact->new($cc);
    $contact->{$_} = $contact_data{$_} for keys %contact_data;

    # Call code under test.
    ok( $contact->save(), 'save() success' );

    # Verify request made via mock UA.
    my $requests = $test->{ua_module}->requests;
    cmp_http_requests(
        $requests,
        [
            {
                method => 'PUT',
                url => 'https://api.constantcontact.com/ws/customers/username/contacts/1',
                content => xml({
                    xmlns => 'http://www.w3.org/2005/Atom',
                    id => 'http://api.constantcontact.com/ws/customers/username/contacts/1',
                    title => {
                        type => 'text',
                    },
                    author => {},
                    updated => re(qr/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/),
                    summary => {
                        type => 'text',
                        content => 'Contact',
                    },
                    content => {
                        type => 'application/vnd.ctct+xml',
                        Contact => {
                            xmlns => 'http://ws.constantcontact.com/ns/1.0/',
                            id => [ ('http://api.constantcontact.com/ws/customers/username/contacts/1') x 2 ],
                            EmailAddress => 'jdoe@acme.company.com',
                            Name => 'John Doe',
                            FirstName => 'John',
                            LastName => 'Doe',
                            CompanyName => 'Acme Corp',
                            WorkPhone => '555-555-1234',
                            Addr1 => '123 Any St',
                            StateCode => 'MA',
                            StateName => 'Massachusetts',
                            PostalCode => '01234',
                            OptInSource => 'ACTION_BY_CUSTOMER',
                            ContactLists => {},
                        },
                    },
                }),
            }
        ],
        "HTTP requests",
    ) or diag(Data::Dumper->Dump([$requests], ['requests']));

    # Verify object.
    cmp_deeply(
        $contact,
        _contact_cmp($cc),
        "Email::ConstantContact::Contact object",
    ) or diag(Data::Dumper->Dump([$contact], ['contact']));
}


1;

} # BEGIN
