#!/usr/bin/env perl
use strict;
use warnings;

t::lib::Email::ConstantContact::getActivity->runtests;


BEGIN {
package t::lib::Email::ConstantContact::getActivity;
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

t::lib::Email::ConstantContact::getActivity - Unit test the C<< Email::ConstantContact->getActivity() >> method.

=head1 SYNOPSIS

    # run all tests  
    prove -lv t/lib/Email/ConstantContact/getActivity.t

    # run single test method
    TEST_METHOD=test_METHOD_NAME prove -lv t/lib/Email/ConstantContact/getActivity.t

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

    # The following sample XML comes from the API docs.
    my $entry_xml = <<'END_OF_XML';
<entry xmlns="http://www.w3.org/2005/Atom">
  <id>http://api.constantcontact.com/ws/customers/username/activities/activityname</id>
  <title type="text"></title>
  <updated>2008-04-29T19:36:10.948Z</updated>

  <content type="application/vnd.ctct+xml">
    <Activity xmlns="http://ws.constantcontact.com/ns/1.0/"
      id="http://api.constantcontact.com/ws/customers/username/activities/activityname">
      <Type>ADD_CONTACT_DETAIL</Type>
      <Status>COMPLETE</Status>
      <Errors>
        <Error>
          <LineNumber>3</LineNumber>
          <EmailAddress>test2@test.com</EmailAddress>
          <Message>Unknown US/Canadian state/prov "Test2"</Message>
        </Error>
        <Error>
          <LineNumber>4</LineNumber>
          <EmailAddress>test3@test.com</EmailAddress>
          <Message>Unknown US/Canadian state/prov "Test3"</Message>
        </Error>
      </Errors>
      <FileName></FileName>
      <TransactionCount>1</TransactionCount>
      <RunStartTime>2008-04-29T19:36:08.894Z</RunStartTime>
      <RunFinishTime>2008-04-29T19:36:10.948Z</RunFinishTime>
      <InsertTime>2008-04-29T19:35:54.923Z</InsertTime>
    </Activity>
  </content>
  <source>
    <id>http://api.constantcontact.com/ws/customers/username/activities</id>
    <title type="text">Bulk Activity</title>
    <link href="" />
    <link href="" rel="self" />
    <author>
      <name>username</name>
    </author>
    <updated>2008-04-29T19:45:24.131Z</updated>
  </source>
</entry>
END_OF_XML

    # Set XML to be returned from mock HTTP request.
    $test->{ua_module}->response_content( $entry_xml );

    # Instantiate CC object.
    my $cc = Email::ConstantContact->new('apikey', 'username', 'password');

    # Call code under test.
    my $activity = $cc->getActivity('activityname');

    # Verify request made via mock UA.
    my $requests = $test->{ua_module}->requests;
    cmp_http_requests(
        $requests,
        [
            'https://api.constantcontact.com/ws/customers/username/activities/activityname',
        ],
        "HTTP requests",
    ) or diag(Data::Dumper->Dump([$requests], ['requests']));

    # Verify activity object returned.
    cmp_deeply(
        $activity,
        all(
            isa('Email::ConstantContact::Activity'),
            noclass({
                '_cc' => shallow($cc),
                'id' => 'http://api.constantcontact.com/ws/customers/username/activities/activityname',
                'Type' => 'ADD_CONTACT_DETAIL',
                'Status' => 'COMPLETE',
                'Error' => undef,
                'Errors' => [
                    {
                        'LineNumber' => '3',
                        'EmailAddress' => 'test2@test.com',
                        'Message' => 'Unknown US/Canadian state/prov "Test2"'
                    },
                    {
                        'EmailAddress' => 'test3@test.com',
                        'Message' => 'Unknown US/Canadian state/prov "Test3"',
                        'LineNumber' => '4'
                    }
                ],
                'FileName' => undef,
                'TransactionCount' => '1',
                'RunStartTime' => '2008-04-29T19:36:08.894Z',
                'RunFinishTime' => '2008-04-29T19:36:10.948Z',
                'InsertTime' => '2008-04-29T19:35:54.923Z',
            }),
        ),
        "Email::ConstantContact::Activity object",
    ) or diag(Data::Dumper->Dump([$activity], ['activity']));
}


1;

} # BEGIN
