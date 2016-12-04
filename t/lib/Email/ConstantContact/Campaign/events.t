#!/usr/bin/env perl
use strict;
use warnings;

t::lib::Email::ConstantContact::Campaign::events->runtests;


BEGIN {
package t::lib::Email::ConstantContact::Campaign::events;
use strict;
use warnings;

use parent 'Test::Class';

use Test::Most;
use Data::Dumper;


use t::lib::Email::ConstantContact::MockUserAgent;
use t::lib::Email::ConstantContact::TestHttpRequest qw(cmp_http_requests);


# load code to be tested
use Email::ConstantContact;


=head1 NAME

t::lib::Email::ConstantContact::Campaign::events - Unit test the C<< Email::ConstantContact::Campaign->events() >> method.

=head1 SYNOPSIS

    # run all tests  
    prove -lv t/lib/Email/ConstantContact/Campaign/events.t

    # run single test method
    TEST_METHOD=test_METHOD_NAME prove -lv t/lib/Email/ConstantContact/Campaign/events.t

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

# Return ( key => value ) of campaign data.
sub _campaign_data {
    return (
        id => 'http://api.constantcontact.com/ws/customers/username/campaigns/1',
        link => '/ws/customers/username/campaigns/1',
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

Test calling events('bounces').

=cut

sub test_smoke : Test(2) {
    my $test = shift;

    # Set Data::Dumper format for diag statements below.
    local $Data::Dumper::Sortkeys = 1;
    local $Data::Dumper::Indent = 1;
    local $Data::Dumper::Useqq = 1;

    my $feed1_xml = <<'END_OF_XML';
<feed xmlns="http://www.w3.org/2005/Atom">
  <id>http://api.constantcontact.com/ws/customers/username/campaigns/1/events/bounces</id>
  <title type="text">Send Events for Customer: username, Campaign id: 1</title>
  <link href="" />
  <link href="" rel="self" />
  <author>
    <name>username</name>
  </author>
  <updated>2008-08-07T20:27:04.627Z</updated>
  <link href="/ws/customers/username/campaigns/1/events/bounces?next=6" rel="next" />
  <link href="/ws/customers/username/campaigns/1/events/bounces" rel="first" />
  <link href="/ws/customers/username/campaigns/1/events/bounces" rel="current" />
  <entry>
    <id>http://api.constantcontact.com/ws/customers/username/campaigns/1/events/bounces</id>
    <title type="text">Email Send Event for Customer: username, Campaign: http://api.constantcontact.com/ws/customers/username/campaigns/1</title>
    <updated>2008-08-05T16:50:04.534Z</updated>
    <author>
      <name>Constant Contact</name>
    </author>
    <content type="application/vnd.ctct+xml">
      <BounceEvent xmlns="http://ws.constantcontact.com/ns/1.0/" id="http://api.constantcontact.com/ws/customers/username/campaigns/1/events/bounces/1">
        <Contact id="http://api.constantcontact.com/ws/customers/username/contacts/1">
          <EmailAddress>joeschmoe@example.net</EmailAddress>
          <link xmlns="http://www.w3.org/2005/Atom" href="http://api.constantcontact.com/ws/customers/username/contacts/1" rel="self" />
        </Contact>
        <Campaign id="http://api.constantcontact.com/ws/customers/username/campaigns/1">
          <link xmlns="http://www.w3.org/2005/Atom" href="http://api.constantcontact.com/ws/customers/username/campaigns/1" rel="self" />
        </Campaign>
        <EventTime>2008-08-05T16:50:04.534Z</EventTime>
      </BounceEvent>
    </content>
  </entry>
</feed>
END_OF_XML

    my $feed2_xml = <<'END_OF_XML';
<feed xmlns="http://www.w3.org/2005/Atom">
  <id>http://api.constantcontact.com/ws/customers/username/campaigns/1/events/bounces</id>
  <title type="text">Send Events for Customer: username, Campaign id: 1</title>
  <link href="" />
  <link href="" rel="self" />
  <author>
    <name>username</name>
  </author>
  <updated>2008-08-07T20:27:05.234Z</updated>
  <link href="/ws/customers/username/campaigns/1/events/bounces" rel="first" />
  <link href="/ws/customers/username/campaigns/1/events/bounces" rel="current" />
  <entry>
    <id>http://api.constantcontact.com/ws/customers/username/campaigns/1/events/bounces</id>
    <title type="text">Email Send Event for Customer: username, Campaign: http://api.constantcontact.com/ws/customers/username/campaigns/1</title>
    <updated>2008-08-05T16:50:05.123Z</updated>
    <author>
      <name>Constant Contact</name>
    </author>
    <content type="application/vnd.ctct+xml">
      <BounceEvent xmlns="http://ws.constantcontact.com/ns/1.0/" id="http://api.constantcontact.com/ws/customers/username/campaigns/1/events/bounces/2">
        <Contact id="http://api.constantcontact.com/ws/customers/username/contacts/2">
          <EmailAddress>ianjones@example.net</EmailAddress>
          <link xmlns="http://www.w3.org/2005/Atom" href="http://api.constantcontact.com/ws/customers/username/contacts/2" rel="self" />
        </Contact>
        <Campaign id="http://api.constantcontact.com/ws/customers/username/campaigns/1">
          <link xmlns="http://www.w3.org/2005/Atom" href="http://api.constantcontact.com/ws/customers/username/campaigns/1" rel="self" />
        </Campaign>
        <EventTime>2008-08-06T17:40:02.123Z</EventTime>
      </BounceEvent>
    </content>
  </entry>
</feed>
END_OF_XML

    # Set XML to be returned from mock HTTP request.
    $test->{ua_module}->response_content( $feed1_xml, $feed2_xml );

    # Campaign data for testing.
    my %campaign_data = _campaign_data;

    # Instantiate CC object.
    my $cc = Email::ConstantContact->new('apikey', 'username', 'password');

    # Instantiate and initialize Campaign object.
    my $campaign = Email::ConstantContact::Campaign->new($cc);
    $campaign->{$_} = $campaign_data{$_} for keys %campaign_data;

    # Call code under test.
    my @events = $campaign->events('bounces');

    # Verify request made via mock UA.
    my $requests = $test->{ua_module}->requests;
    cmp_http_requests(
        $requests,
        [
            {
                method => 'GET',
                url => 'https://api.constantcontact.com/ws/customers/username/campaigns/1/events/bounces',
            },
            {
                method => 'GET',
                url => 'https://api.constantcontact.com/ws/customers/username/campaigns/1/events/bounces?next=6',
            },
        ],
        "HTTP requests",
    ) or diag(Data::Dumper->Dump([$requests], ['requests']));

    # Verify returned objects.
    cmp_deeply(
        \@events,
        [
            all(
                isa('Email::ConstantContact::CampaignEvent'),
                noclass(superhashof({
                    _cc => shallow($cc),
                    id => 'http://api.constantcontact.com/ws/customers/username/campaigns/1/events/bounces/1',
                    Contact => all(
                        isa('Email::ConstantContact::Contact'),
                        noclass(superhashof({
                            id => 'http://api.constantcontact.com/ws/customers/username/contacts/1',
                            EmailAddress => 'joeschmoe@example.net',
                        })),
                    ),
                    Campaign => all(
                        isa('Email::ConstantContact::Campaign'),
                        noclass(superhashof({
                            id => 'http://api.constantcontact.com/ws/customers/username/campaigns/1',
                        })),
                    ),
                    EventTime => '2008-08-05T16:50:04.534Z',
                })),
            ),
            all(
                isa('Email::ConstantContact::CampaignEvent'),
                noclass(superhashof({
                    _cc => shallow($cc),
                    id => 'http://api.constantcontact.com/ws/customers/username/campaigns/1/events/bounces/2',
                    Contact => all(
                        isa('Email::ConstantContact::Contact'),
                        noclass(superhashof({
                            id => 'http://api.constantcontact.com/ws/customers/username/contacts/2',
                            EmailAddress => 'ianjones@example.net',
                        })),
                    ),
                    Campaign => all(
                        isa('Email::ConstantContact::Campaign'),
                        noclass(superhashof({
                            id => 'http://api.constantcontact.com/ws/customers/username/campaigns/1',
                        })),
                    ),
                    EventTime => '2008-08-06T17:40:02.123Z',
                })),
            ),
        ],
        "Email::ConstantContact::CampaignEvent objects",
    ) or diag(Data::Dumper->Dump([\@events], ['*events']));
}


1;

} # BEGIN
