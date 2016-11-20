#!/usr/bin/env perl
use strict;
use warnings;

t::lib::Email::ConstantContact::campaigns->runtests;


BEGIN {
package t::lib::Email::ConstantContact::campaigns;
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

t::lib::Email::ConstantContact::campaigns - Unit test the C<< Email::ConstantContact->campaigns() >> method.

=head1 SYNOPSIS

    # run all tests  
    prove -lv t/lib/Email/ConstantContact/campaigns.t

    # run single test method
    TEST_METHOD=test_METHOD_NAME prove -lv t/lib/Email/ConstantContact/campaigns.t

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

=cut

sub test_smoke : Test(2) {
    my $test = shift;

    # Set Data::Dumper format for diag statements below.
    local $Data::Dumper::Sortkeys = 1;
    local $Data::Dumper::Indent = 1;
    local $Data::Dumper::Useqq = 1;

    # The following is based on sample XML from the API docs.
    my $feed_xml = <<'END_OF_XML';
<?xml version='1.0' encoding='UTF-8'?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <id>http://api.constantcontact.com/ws/customers/username/campaigns</id>
  <title type="text">Campaigns for customer: username</title>
  <link href="campaigns" />
  <link href="campaigns" rel="self" />
  <author>
    <name>username</name>
  </author>
  <updated>2009-10-19T18:55:01.918Z</updated>
  <link href="/ws/customers/username/campaigns?next=2" rel="next" />
  <link href="/ws/customers/username/campaigns" rel="current" />
  <link href="/ws/customers/username/campaigns" rel="first" />
  <entry>
    <link href="/ws/customers/username/campaigns/1100546096289" rel="edit" />
    <id>http://api.constantcontact.com/ws/customers/username/campaigns/1100546096289</id>
    <title type="text">Spring Campaign</title>
    <updated>2009-10-19T18:34:53.105Z</updated>
    <author>
      <name>Constant Contact</name>
    </author>
    <content type="application/vnd.ctct+xml">
      <Campaign xmlns="http://ws.constantcontact.com/ns/1.0/" id="http://api.constantcontact.com/ws/customers/username/campaigns/1100546096289">
        <Name>Spring Campaign</Name>
        <Status>Sent</Status>
        <Date>2009-10-19T18:34:53.105Z</Date>
      </Campaign>
    </content>
  </entry>
  <entry>
    <link href="/ws/customers/username/campaigns/1100546028219" rel="edit" />
    <id>http://api.constantcontact.com/ws/customers/username/campaigns/1100546028219</id>
    <title type="text">Fall Campaign</title>
    <updated>2009-10-16T13:55:48.369Z</updated>
    <author>
      <name>Constant Contact</name>
    </author>
    <content type="application/vnd.ctct+xml">
      <Campaign xmlns="http://ws.constantcontact.com/ns/1.0/" id="http://api.constantcontact.com/ws/customers/username/campaigns/1100546028219">
        <Name>Fall Campaign</Name>
        <Status>Draft</Status>
        <Date>2009-10-16T13:55:48.369Z</Date>
      </Campaign>
    </content>
  </entry>
</feed>
END_OF_XML

    # Set XML to be returned from mock HTTP request.
    $test->{ua_module}->response_content( $feed_xml );

    # Instantiate CC object.
    my $cc = Email::ConstantContact->new('apikey', 'username', 'password');

    # Call code under test.
    my @campaigns = $cc->campaigns;

    # Verify request made via mock UA.
    my $requests = $test->{ua_module}->requests;
    cmp_http_requests(
        $requests,
        [
            'https://api.constantcontact.com/ws/customers/username/campaigns',
        ],
        "HTTP requests",
    ) or diag(Data::Dumper->Dump([$requests], ['requests']));

    # Verify activity object returned.
    cmp_deeply(
        \@campaigns,
        [
            all(
                isa('Email::ConstantContact::Campaign'),
                noclass(superhashof({
                    _cc => shallow($cc),
                    Name => 'Spring Campaign',
                    Status => 'Sent',
                    Date => '2009-10-19T18:34:53.105Z',
                })),
            ),
            all(
                isa('Email::ConstantContact::Campaign'),
                noclass(superhashof({
                    _cc => shallow($cc),
                    Name => 'Fall Campaign',
                    Status => 'Draft',
                    Date => '2009-10-16T13:55:48.369Z',
                })),
            ),
        ],
        "Email::ConstantContact::Campaign objects",
    ) or diag(Data::Dumper->Dump([\@campaigns], ['*campaigns']));
}


1;

} # BEGIN
