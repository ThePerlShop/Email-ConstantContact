#!/usr/bin/env perl
use strict;
use warnings;

t::lib::Email::ConstantContact::newContact->runtests;


BEGIN {
package t::lib::Email::ConstantContact::newContact;
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

t::lib::Email::ConstantContact::newContact - Unit test the C<< Email::ConstantContact->newContact() >> method.

=head1 SYNOPSIS

    # run all tests  
    prove -lv t/lib/Email/ConstantContact/newContact.t

    # run single test method
    TEST_METHOD=test_METHOD_NAME prove -lv t/lib/Email/ConstantContact/newContact.t

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

# Return XML for a contact.
sub _contact_xml {
    return <<'END_OF_XML';
<entry xmlns="http://www.w3.org/2005/Atom">
  <id>http://api.constantcontact.com/ws/customers/username/contacts/1</id>
  <title type="text">Contact</title>
  <link href="" rel="self" />
  <author>
    <name>Constant Contact Web Services</name>
  </author>
  <updated>2008-04-16T13:07:13.453Z</updated>
  <link href="lists" rel="first" />
  <link href="lists" rel="current" />
  <link href="/ws/customers/username/contacts/1" rel="edit" />
  <id>http://api.constantcontact.com/ws/customers/username/contacts/1</id>
  <updated>2008-04-16T13:07:14.057Z</updated>
  <content type="application/vnd.ctct+xml">
    <Contact xmlns="http://ws.constantcontact.com/ns/1.0/"
        id="http://api.constantcontact.com/ws/customers/username/contacts/1">
      <Name>John Doe</Name>
      <FirstName>John</FirstName>
      <LastName>Doe</LastName>
      <CompanyName>Acme Corp</CompanyName>
      <WorkPhone>555-555-1234</WorkPhone>
      <Addr1>123 Any St</Addr1>
      <StateCode>MA</StateCode>
      <StateName>Massachusetts</StateName>
      <PostalCode>01234</PostalCode>
      <EmailAddress>jdoe@acme.company.com</EmailAddress>
    </Contact>
  </content>
</entry>
END_OF_XML
}

# Return ( key => value ) of contact data for the contact above.
sub _contact_data {
    return (
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

Test calling newContact($email, \%data).

=cut

sub test_smoke : Test(2) {
    my $test = shift;

    # Set Data::Dumper format for diag statements below.
    local $Data::Dumper::Sortkeys = 1;
    local $Data::Dumper::Indent = 1;
    local $Data::Dumper::Useqq = 1;

    # Set XML and HTTP code to be returned from mock HTTP request.
    $test->{ua_module}->response_code( 201 );
    $test->{ua_module}->response_content( _contact_xml );

    # Contact data for testing.
    my %contact_data = _contact_data;
    my $contact_email = delete $contact_data{EmailAddress};

    # Instantiate CC object.
    my $cc = Email::ConstantContact->new('apikey', 'username', 'password');

    # Call code under test.
    my $contact = $cc->newContact($contact_email, \%contact_data);

    # Verify request made via mock UA.
    my $requests = $test->{ua_module}->requests;
    cmp_http_requests(
        $requests,
        [
            {
                method => 'POST',
                url => 'https://api.constantcontact.com/ws/customers/username/contacts',
                content => xml({
                    xmlns => 'http://www.w3.org/2005/Atom',
                    id => 'data:,none',
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

    # Verify activity object returned.
    cmp_deeply(
        $contact,
        _contact_cmp($cc),
        "Email::ConstantContact::Contact object",
    ) or diag(Data::Dumper->Dump([$contact], ['contact']));
}


1;

} # BEGIN
