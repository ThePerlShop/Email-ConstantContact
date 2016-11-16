#!/usr/bin/env perl
use strict;
use warnings;

t::lib::Email::ConstantContact::getContact->runtests;


BEGIN {
package t::lib::Email::ConstantContact::getContact;
use strict;
use warnings;

use parent 'Test::Class';

use Test::Most;
use Data::Dumper;


use t::lib::Email::ConstantContact::MockUserAgent;


# load code to be tested
use Email::ConstantContact;


=head1 NAME

t::lib::Email::ConstantContact::getContact - Unit test the C<< Email::ConstantContact->getContact() >> method.

=head1 SYNOPSIS

    # run all tests  
    prove -lv t/lib/Email/ConstantContact/getContact.t

    # run single test method
    TEST_METHOD=test_METHOD_NAME prove -lv t/lib/Email/ConstantContact/getContact.t

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

# Return a Test::Deep comparator tree for the contact above.
sub _contact_cmp {
    my ($cc) = @_;
    return all(
        isa('Email::ConstantContact::Contact'),
        noclass(superhashof({
            _cc => shallow($cc),
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
        })),
    );
}

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

=head2 test_url

Test calling getContact($url).

=cut

sub test_url : Test(2) {
    my $test = shift;

    # Set Data::Dumper format for diag statements below.
    local $Data::Dumper::Sortkeys = 1;
    local $Data::Dumper::Indent = 1;
    local $Data::Dumper::Useqq = 1;

    # Set XML to be returned from mock HTTP request.
    $test->{ua_module}->response_content( _contact_xml );

    # Instantiate CC object.
    my $cc = Email::ConstantContact->new('apikey', 'username', 'password');

    # Call code under test.
    # (The code under test should lowercase capital letters convert http to https.)
    my $contact = $cc->getContact('http://API.ConstantContact.com/ws/customers/username/contacts/1');

    # Verify request made via mock UA.
    my $requests = $test->{ua_module}->requests;
    cmp_deeply(
        $requests,
        [
            _http_request_cmp('https://api.constantcontact.com/ws/customers/username/contacts/1'),
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


=head2 test_email

Test calling getContact($email).

=cut

sub test_email : Test(2) {
    my $test = shift;

    # Set Data::Dumper format for diag statements below.
    local $Data::Dumper::Sortkeys = 1;
    local $Data::Dumper::Indent = 1;
    local $Data::Dumper::Useqq = 1;

    my $contacts_xml = <<'END_OF_XML';
<feed xmlns="http://www.w3.org/2005/Atom">
  <id>http://api.constantcontact.com/ws/customers/username/contacts</id>
  <title type="text">Contacts</title>
  <link href="" rel="self" />
  <author>
    <name>Constant Contact Web Services</name>
  </author>
  <updated>2008-04-16T13:07:13.453Z</updated>
  <link href="lists" rel="first" />
  <link href="lists" rel="current" />
  <entry>
    <link href="/ws/customers/username/contacts/1" rel="edit" />
    <id>http://api.constantcontact.com/ws/customers/username/contacts/1</id>
    <updated>2008-04-16T13:07:14.057Z</updated>
    <content type="application/vnd.ctct+xml">
      <Contact xmlns="http://ws.constantcontact.com/ns/1.0/"
          id="http://api.constantcontact.com/ws/customers/username/contacts/1">
        <Name>John Doe</Name>
        <EmailAddress>jdoe@acme.company.com</EmailAddress>
      </Contact>
    </content>
  </entry>
[</feed>
END_OF_XML


    # Set XML to be returned from mock HTTP request.
    $test->{ua_module}->response_content( $contacts_xml, _contact_xml );

    # Instantiate CC object.
    my $cc = Email::ConstantContact->new('apikey', 'username', 'password');

    # Call code under test.
    # (The code under test should lowercase capital letters convert http to https.)
    my $contact = $cc->getContact('jdoe@acme.company.com');

    # Verify request made via mock UA.
    my $requests = $test->{ua_module}->requests;
    cmp_deeply(
        $requests,
        [
            _http_request_cmp('https://api.constantcontact.com/ws/customers/username/contacts?email=jdoe%40acme.company.com'),
            _http_request_cmp('https://api.constantcontact.com/ws/customers/username/contacts/1'),
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


=head2 test_number

Test calling getContact($number).

=cut

sub test_number : Test(2) {
    my $test = shift;

    # Set Data::Dumper format for diag statements below.
    local $Data::Dumper::Sortkeys = 1;
    local $Data::Dumper::Indent = 1;
    local $Data::Dumper::Useqq = 1;

    # Set XML to be returned from mock HTTP request.
    $test->{ua_module}->response_content( _contact_xml );

    # Instantiate CC object.
    my $cc = Email::ConstantContact->new('apikey', 'username', 'password');

    # Call code under test.
    # (The code under test should lowercase capital letters convert http to https.)
    my $contact = $cc->getContact(1);

    # Verify request made via mock UA.
    my $requests = $test->{ua_module}->requests;
    cmp_deeply(
        $requests,
        [
            _http_request_cmp('https://api.constantcontact.com/ws/customers/username/contacts/1'),
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
