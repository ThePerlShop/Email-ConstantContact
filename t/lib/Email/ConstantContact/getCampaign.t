#!/usr/bin/env perl
use strict;
use warnings;

t::lib::Email::ConstantContact::getCampaign->runtests;


BEGIN {
package t::lib::Email::ConstantContact::getCampaign;
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

t::lib::Email::ConstantContact::getCampaign - Unit test the C<< Email::ConstantContact->getCampaign() >> method.

=head1 SYNOPSIS

    # run all tests  
    prove -lv t/lib/Email/ConstantContact/getCampaign.t

    # run single test method
    TEST_METHOD=test_METHOD_NAME prove -lv t/lib/Email/ConstantContact/getCampaign.t

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

# Return XML for a campaign.
sub _campaign_xml {
    # The following is based on sample XML from the API docs.
    return <<'END_OF_XML';
<?xml version='1.0' encoding='UTF-8'?>
<entry xmlns="http://www.w3.org/2005/Atom">
  <link href="/ws/customers/username/campaigns" rel="edit" />
  <id>http://api.constantcontact.com/ws/customers/username/campaigns</id>
  <title type="text">API Test Email</title>
  <updated>2009-10-19T18:34:53.105Z</updated>
  <author>
    <name>Constant Contact</name>
  </author>
  <content type="application/vnd.ctct+xml">
    <Campaign xmlns="http://ws.constantcontact.com/ns/1.0/"
id="http://api.constantcontact.com/ws/customers/username/campaigns/1">
      <Name>API Test Email</Name>
      <Status>Draft</Status>
      <Date>2009-10-19T18:34:53.105Z</Date>
      <Subject>Enter email subject here</Subject>
      <FromName>username@example.com</FromName>
      <ViewAsWebpage>NO</ViewAsWebpage>
      <ViewAsWebpageLinkText></ViewAsWebpageLinkText>
      <ViewAsWebpageText></ViewAsWebpageText>
      <PermissionReminder>YES</PermissionReminder>
      <PermissionReminderText>You're receiving this email because of your relationship with ctct. 
Please &lt;ConfirmOptin>&lt;a style="color:#0000ff;">confirm&lt;/a>&lt;/ConfirmOptin> 
your continued interest in receiving email from us.</PermissionReminderText>
      <GreetingSalutation>Dear</GreetingSalutation>
      <GreetingName>FirstName</GreetingName>
      <GreetingString>Greetings!</GreetingString>
      <OrganizationName>ctct</OrganizationName>
      <OrganizationAddress1>123 wsw st</OrganizationAddress1>
      <OrganizationAddress2></OrganizationAddress2>
      <OrganizationAddress3></OrganizationAddress3>
      <OrganizationCity>Ashland</OrganizationCity>
      <OrganizationState>MA</OrganizationState>
      <OrganizationInternationalState></OrganizationInternationalState>
      <OrganizationCountry>us</OrganizationCountry>
      <OrganizationPostalCode>32423</OrganizationPostalCode>
      <IncludeForwardEmail>NO</IncludeForwardEmail>
      <ForwardEmailLinkText></ForwardEmailLinkText>
      <IncludeSubscribeLink>NO</IncludeSubscribeLink>
      <SubscribeLinkText></SubscribeLinkText>
      <EmailContentFormat>HTML</EmailContentFormat>
      <EmailContent>&lt;html lang="en" xml:lang="en" xmlns="http://www.w3.org/1999/xhtml" xmlns:cctd="http://www.constantcontact.com/cctd">
&lt;body>&lt;CopyRight>Copyright (c) 1996-2009 Constant Contact. All rights reserved.  Except as permitted under a separate
written agreement with Constant Contact, neither the Constant Contact software, nor any content that appears on any Constant Contact site,
including but not limited to, web pages, newsletters, or templates may be reproduced, republished, repurposed, or distributed without the
prior written permission of Constant Contact.  For inquiries regarding reproduction or distribution of any Constant Contact material, please
contact username@example.com.&lt;/CopyRight>
&lt;OpenTracking/>
&lt;!--  Do NOT delete previous line if you want to get statistics on the number of opened emails -->
&lt;CustomBlock name="letter.intro" title="Personalization">
&lt;Greeting/>
&lt;/CustomBlock>
&lt;/body>
&lt;/html></EmailContent>
      <EmailTextContent>&lt;Text>This is the text version.&lt;/Text></EmailTextContent>
      <StyleSheet></StyleSheet>
      <ContactLists>
        <ContactList id="http://api.constantcontact.com/ws/customers/username/lists/1">
          <link xmlns="http://www.w3.org/2005/Atom" href="/ws/customers/username/lists/1" rel="self" />
        </ContactList>
      </ContactLists>
      <FromEmail>
        <Email id="http://api.constantcontact.com/ws/customers/username/settings/emailaddresses/1">
          <link xmlns="http://www.w3.org/2005/Atom" href="/ws/customers/username/settings/emailaddresses/1"
          rel="self" />
        </Email>
        <EmailAddress>username@example.com</EmailAddress>
      </FromEmail>
      <ReplyToEmail>
        <Email id="http://api.constantcontact.com/ws/customers/username/settings/emailaddresses/1">
          <link xmlns="http://www.w3.org/2005/Atom" href="/ws/customers/username/settings/emailaddresses/1"
          rel="self" />
        </Email>
        <EmailAddress>username@example.com</EmailAddress>
      </ReplyToEmail>
    </Campaign>
  </content>
  <source>
    <id>http://api.constantcontact.com/ws/customers/username/campaigns</id>
    <title type="text">Campaigns for customer: username</title>
    <link href="campaigns" />
    <link href="campaigns" rel="self" />
    <author>
      <name>username</name>
    </author>
    <updated>2009-10-19T19:36:12.622Z</updated>
  </source>
</entry>
END_OF_XML
}

# Return a Test::Deep comparator tree for the campaign above.
sub _campaign_cmp {
    my ($cc) = @_;
    return all(
        isa('Email::ConstantContact::Campaign'),
        noclass(superhashof({
            _cc => shallow($cc),
            Name => 'API Test Email',
            Status => 'Draft',
            Date => '2009-10-19T18:34:53.105Z',
            Subject => 'Enter email subject here',
            FromName => 'username@example.com',
            ViewAsWebpage => 'NO',
            ViewAsWebpageLinkText => undef,
            PermissionReminder => 'YES',
            GreetingSalutation => 'Dear',
            GreetingName => 'FirstName',
            GreetingString => 'Greetings!',
            OrganizationName => 'ctct',
            OrganizationAddress1 => '123 wsw st',
            OrganizationAddress2 => undef,
            OrganizationAddress3 => undef,
            OrganizationCity => 'Ashland',
            OrganizationState => 'MA',
            OrganizationInternationalState => undef,
            OrganizationCountry => 'us',
            OrganizationPostalCode => '32423',
            IncludeForwardEmail => 'NO',
            ForwardEmailLinkText => undef,
            IncludeSubscribeLink => 'NO',
            SubscribeLinkText => undef,
            EmailContentFormat => 'HTML',
            EmailContent => '<html lang="en" xml:lang="en" xmlns="http://www.w3.org/1999/xhtml" xmlns:cctd="http://www.constantcontact.com/cctd">
<body><CopyRight>Copyright (c) 1996-2009 Constant Contact. All rights reserved.  Except as permitted under a separate
written agreement with Constant Contact, neither the Constant Contact software, nor any content that appears on any Constant Contact site,
including but not limited to, web pages, newsletters, or templates may be reproduced, republished, repurposed, or distributed without the
prior written permission of Constant Contact.  For inquiries regarding reproduction or distribution of any Constant Contact material, please
contact username@example.com.</CopyRight>
<OpenTracking/>
<!--  Do NOT delete previous line if you want to get statistics on the number of opened emails -->
<CustomBlock name="letter.intro" title="Personalization">
<Greeting/>
</CustomBlock>
</body>
</html>',
            EmailTextContent => '<Text>This is the text version.</Text>',
            StyleSheet => undef,
            ContactLists => {
                ContactList => {
                    id => 'http://api.constantcontact.com/ws/customers/username/lists/1',
                    link => [
                        {
                            xmlns => 'http://www.w3.org/2005/Atom',
                            href => '/ws/customers/username/lists/1',
                            rel => 'self',
                        },
                    ],
                },
            },
            FromEmail => {
                Email => {
                    id => 'http://api.constantcontact.com/ws/customers/username/settings/emailaddresses/1',
                    link => [
                        {
                            xmlns => 'http://www.w3.org/2005/Atom',
                            href => '/ws/customers/username/settings/emailaddresses/1',
                            rel => 'self',
                        },
                    ],
                },
                EmailAddress => 'username@example.com',
            },
            ReplyToEmail => {
                Email => {
                    id => 'http://api.constantcontact.com/ws/customers/username/settings/emailaddresses/1',
                    link => [
                        {
                            xmlns => 'http://www.w3.org/2005/Atom',
                            href => '/ws/customers/username/settings/emailaddresses/1',
                            rel => 'self',
                        },
                    ],
                },
                EmailAddress => 'username@example.com',
            },
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

=head2 test_url

Test calling getCampaign($url).

=cut

sub test_url : Test(2) {
    my $test = shift;

    # Set Data::Dumper format for diag statements below.
    local $Data::Dumper::Sortkeys = 1;
    local $Data::Dumper::Indent = 1;
    local $Data::Dumper::Useqq = 1;

    # Set XML to be returned from mock HTTP request.
    $test->{ua_module}->response_content( _campaign_xml );

    # Instantiate CC object.
    my $cc = Email::ConstantContact->new('apikey', 'username', 'password');

    # Call code under test.
    # (The code under test should lowercase capital letters convert http to https.)
    my $campaign = $cc->getCampaign('http://API.ConstantContact.com/ws/customers/username/campaigns/1');

    # Verify request made via mock UA.
    my $requests = $test->{ua_module}->requests;
    cmp_http_requests(
        $requests,
        [
            'https://api.constantcontact.com/ws/customers/username/campaigns/1',
        ],
        "HTTP requests",
    ) or diag(Data::Dumper->Dump([$requests], ['requests']));

    # Verify activity object returned.
    cmp_deeply(
        $campaign,
        _campaign_cmp($cc),
        "Email::ConstantContact::Campaign object",
    ) or diag(Data::Dumper->Dump([$campaign], ['campaign']));
}


=head2 test_number

Test calling getCampaign($number).

=cut

sub test_number : Test(2) {
    my $test = shift;

    # Set Data::Dumper format for diag statements below.
    local $Data::Dumper::Sortkeys = 1;
    local $Data::Dumper::Indent = 1;
    local $Data::Dumper::Useqq = 1;

    # Set XML to be returned from mock HTTP request.
    $test->{ua_module}->response_content( _campaign_xml );

    # Instantiate CC object.
    my $cc = Email::ConstantContact->new('apikey', 'username', 'password');

    # Call code under test.
    # (The code under test should lowercase capital letters convert http to https.)
    my $campaign = $cc->getCampaign(1);

    # Verify request made via mock UA.
    my $requests = $test->{ua_module}->requests;
    cmp_http_requests(
        $requests,
        [
            'https://api.constantcontact.com/ws/customers/username/campaigns/1',
        ],
        "HTTP requests",
    ) or diag(Data::Dumper->Dump([$requests], ['requests']));

    # Verify activity object returned.
    cmp_deeply(
        $campaign,
        _campaign_cmp($cc),
        "Email::ConstantContact::Campaign object",
    ) or diag(Data::Dumper->Dump([$campaign], ['campaign']));
}


1;

} # BEGIN
