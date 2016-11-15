#!/usr/bin/env perl
use strict;
use warnings;

t::contacts->runtests;


BEGIN {
package t::contacts;
use strict;
use warnings;

use parent 'Test::Class';

use Test::Most;
use Data::Dumper;


use Test::MockObject;
use Test::MockModule;


# load code to be tested
use Email::ConstantContact;


=head1 NAME

t::contacts - Unit test the C<< Email::ConstantContact->contacts() >> method.

=head1 SYNOPSIS

    # run all tests  
    prove -lv t/05-contacts.t

    # run single test method
    TEST_METHOD=test_METHOD_NAME prove -lv t/05-contacts.t

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


## Startup/shutdown/setup/teardown methods

# Setup mock overrides for module functions.
sub _mock_modules : Test(setup) {
    my $test = shift;

    # mock HTTP response content
    $test->{ua_response_content} = ''; # override in test if desired

    # where to save requests made of the user agent
    $test->{ua_requests} = [];

    # mock LWP::UserAgent->request()
    my $ua = $test->{ua} = Test::MockModule->new('LWP::UserAgent');
    $ua->mock( request => sub {
        my $self = shift;
        my ($request) = @_;
        push @{$test->{ua_requests}}, $request;

        # mock HTTP response
        my $response = Test::MockObject->new();
        $response->set_always( code => 200 );
        $response->set_always( content => $test->{ua_response_content} );
        return $response;
    } );
}

# Cleanup mock overrides.
sub _unmock_modules : Test(teardown) {
    my $test = shift;

    delete $test->{ua};
    delete $test->{ua_requests};
    delete $test->{ua_response_content};
}


## Tests

=head1 TESTS

=head2 test_smoke

=cut

sub test_smoke : Test(2) {
    my $test = shift;

    # Set Data::Dumper format for diag statements below.
    local $Data::Dumper::Sortkeys = 1;
    local $Data::Dumper::Indent = 1;
    local $Data::Dumper::Useqq = 1;

    my $feed_xml = <<'END_OF_XML';
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
  <entry>
    <link href="/ws/customers/username/contacts/2" rel="edit" />
    <id>http://api.constantcontact.com/ws/customers/username/contacts/2</id>
    <updated>2008-04-16T13:07:15.201Z</updated>
    <content type="application/vnd.ctct+xml">
      <Contact xmlns="http://ws.constantcontact.com/ns/1.0/"
          id="http://api.constantcontact.com/ws/customers/username/contacts/2">
        <Name>Joe Schmoe</Name>
        <EmailAddress>jschmoe@company.com</EmailAddress>
      </Contact>
    </content>
  </entry>
</feed>
END_OF_XML

    # Set XML to be returned from mock HTTP request.
    $test->{ua_response_content} = $feed_xml;

    # Instantiate CC object.
    my $cc = Email::ConstantContact->new('apikey', 'username', 'password');

    # Call code under test.
    my @contacts = $cc->contacts;

    # Verify request made via mock UA.
    cmp_deeply(
        $test->{ua_requests},
        [
            all(
                isa('HTTP::Request'),
                methods(
                    method => 'GET',
                    uri => methods(
                        as_string => 'https://api.constantcontact.com/ws/customers/username/contacts',
                    ),
                    [ header => 'authorization' ] => 'Basic YXBpa2V5JXVzZXJuYW1lOnBhc3N3b3Jk',
                ),
            ),
        ],
        "HTTP request",
    ) or diag(Data::Dumper->Dump([$test->{ua_requests}], ['requests']));;

    # Verify activity object returned.
    cmp_deeply(
        \@contacts,
        [
            all(
                isa('Email::ConstantContact::Contact'),
                noclass(superhashof({
                    _cc => shallow($cc),
                    Name => 'John Doe',
                    EmailAddress => 'jdoe@acme.company.com',
                })),
            ),
            all(
                isa('Email::ConstantContact::Contact'),
                noclass(superhashof({
                    _cc => shallow($cc),
                    Name => 'Joe Schmoe',
                    EmailAddress => 'jschmoe@company.com',
                })),
            ),
        ],
        "Email::ConstantContact::Contact object",
    ) or diag(Data::Dumper->Dump([\@contacts], ['*contacts']));
}


1;

} # BEGIN
