#!/usr/bin/env perl
use strict;
use warnings;

t::lib::Email::ConstantContact::lists->runtests;


BEGIN {
package t::lib::Email::ConstantContact::lists;
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

t::lib::Email::ConstantContact::lists - Unit test the C<< Email::ConstantContact->lists() >> method.

=head1 SYNOPSIS

    # run all tests  
    prove -lv t/lib/Email/ConstantContact/lists.t

    # run single test method
    TEST_METHOD=test_METHOD_NAME prove -lv t/lib/Email/ConstantContact/lists.t

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
    my $list1_xml = <<'END_OF_XML';
<feed xmlns="http://www.w3.org/2005/Atom">
  <id>http://api.constantcontact.com/ws/customers/username/lists</id>
  <title type="text">Contact Lists</title>
  <link href="" />
  <link href="" rel="self" />
  <author>
    <name>Constant Contact Web Services</name>
  </author>
  <updated>2008-04-16T13:07:13.453Z</updated>
  <link href="/ws/customers/username/lists?next=6" rel="next" />
  <link href="lists" rel="first" />
  <link href="lists" rel="current" />
  <entry>
    <link href="/ws/customers/username/lists/1" rel="edit" />
    <id>http://api.constantcontact.com/ws/customers/username/lists/1</id>
    <title type="text">General Interest</title>
    <updated>2008-04-16T13:07:14.057Z</updated>
    <content type="application/vnd.ctct+xml">
      <ContactList xmlns="http://ws.constantcontact.com/ns/1.0/"
          id="http://api.constantcontact.com/ws/customers/username/lists/1">
        <OptInDefault>false</OptInDefault>
        <Name>General Interest</Name>
        <ShortName>General Interest</ShortName>
        <DisplayOnSignup>Yes</DisplayOnSignup>
        <SortOrder>1</SortOrder>
        <Members id="http://api.constantcontact.com/ws/customers/username/lists/1/members"></Members>
        <ContactCount>42</ContactCount>
      </ContactList>
    </content>
  </entry>
  <entry>
    <link href="/ws/customers/username/lists/2" rel="edit" />
    <id>http://api.constantcontact.com/ws/customers/username/lists/2</id>
    <title type="text">Recent Signups</title>
    <updated>2008-04-16T13:07:14.061Z</updated>
    <content type="application/vnd.ctct+xml">
      <ContactList xmlns="http://ws.constantcontact.com/ns/1.0/"
          id="http://api.constantcontact.com/ws/customers/username/lists/2">
        <OptInDefault>false</OptInDefault>
        <Name>Recent Signups</Name>
        <ShortName>Recent Signups</ShortName>
        <DisplayOnSignup>No</DisplayOnSignup>
        <SortOrder>2</SortOrder>
        <Members id="http://api.constantcontact.com/ws/customers/username/lists/2/members"></Members>
        <ContactCount>712</ContactCount>
      </ContactList>
    </content>
  </entry>
</feed>
END_OF_XML

    my $list2_xml = <<'END_OF_XML';
<feed xmlns="http://www.w3.org/2005/Atom">
  <id>http://api.constantcontact.com/ws/customers/username/lists?next=6</id>
  <title type="text">Contact Lists</title>
  <link href="" />
  <link href="" rel="self" />
  <author>
    <name>Constant Contact Web Services</name>
  </author>
  <updated>2008-04-16T13:07:13.453Z</updated>
  <link href="lists" rel="first" />
  <link href="lists" rel="current" />
  <entry>
    <link href="/ws/customers/username/lists/3" rel="edit" />
    <id>http://api.constantcontact.com/ws/customers/username/lists/3</id>
    <title type="text">Miscellaneous</title>
    <updated>2008-04-16T13:07:14.070Z</updated>
    <content type="application/vnd.ctct+xml">
      <ContactList xmlns="http://ws.constantcontact.com/ns/1.0/"
          id="http://api.constantcontact.com/ws/customers/username/lists/3">
        <OptInDefault>true</OptInDefault>
        <Name>Miscellaneous</Name>
        <ShortName>Miscellaneous</ShortName>
        <DisplayOnSignup>No</DisplayOnSignup>
        <SortOrder>3</SortOrder>
        <Members id="http://api.constantcontact.com/ws/customers/username/lists/3/members"></Members>
        <ContactCount>12</ContactCount>
      </ContactList>
    </content>
  </entry>
</feed>
END_OF_XML

    # Set XML to be returned from mock HTTP request.
    $test->{ua_module}->response_content( $list1_xml, $list2_xml );

    # Instantiate CC object.
    my $cc = Email::ConstantContact->new('apikey', 'username', 'password');

    # Call code under test.
    my @lists = $cc->lists;

    # Verify request made via mock UA.
    my $requests = $test->{ua_module}->requests;
    cmp_http_requests(
        $requests,
        [
            'https://api.constantcontact.com/ws/customers/username/lists',
            'https://api.constantcontact.com/ws/customers/username/lists?next=6',
        ],
        "HTTP requests",
    ) or diag(Data::Dumper->Dump([$requests], ['requests']));

    # Verify activity object returned.
    cmp_deeply(
        \@lists,
        [
            all(
                isa('Email::ConstantContact::List'),
                noclass({
                    _cc => shallow($cc),
                    link => "/ws/customers/username/lists/1",
                    id => "http://api.constantcontact.com/ws/customers/username/lists/1",
                    OptInDefault => "false",
                    Name => "General Interest",
                    ShortName => "General Interest",
                    DisplayOnSignup => "Yes",
                    SortOrder => 1,
                }),
            ),
            all(
                isa('Email::ConstantContact::List'),
                noclass({
                    _cc => shallow($cc),
                    link => "/ws/customers/username/lists/2",
                    id => "http://api.constantcontact.com/ws/customers/username/lists/2",
                    OptInDefault => "false",
                    Name => "Recent Signups",
                    ShortName => "Recent Signups",
                    DisplayOnSignup => "No",
                    SortOrder => 2,
                }),
            ),
            all(
                isa('Email::ConstantContact::List'),
                noclass({
                    _cc => shallow($cc),
                    link => "/ws/customers/username/lists/3",
                    id => "http://api.constantcontact.com/ws/customers/username/lists/3",
                    OptInDefault => "true",
                    Name => "Miscellaneous",
                    ShortName => "Miscellaneous",
                    DisplayOnSignup => "No",
                    SortOrder => 3,
                }),
            ),
        ],
        "Email::ConstantContact::List objects",
    ) or diag(Data::Dumper->Dump([\@lists], ['*lists']));
}


1;

} # BEGIN
