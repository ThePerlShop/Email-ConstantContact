#!/usr/bin/env perl
use strict;
use warnings;

t::lib::Email::ConstantContact::Campaign::save->runtests;


BEGIN {
package t::lib::Email::ConstantContact::Campaign::save;
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

t::lib::Email::ConstantContact::Campaign::save - Unit test the C<< Email::ConstantContact::Campaign->save() >> method.

=head1 SYNOPSIS

    # run all tests  
    prove -lv t/lib/Email/ConstantContact/Campaign/save.t

    # run single test method
    TEST_METHOD=test_METHOD_NAME prove -lv t/lib/Email/ConstantContact/Campaign/save.t

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

# Return ( key => value ) of campaign data for the campaign above.
sub _campaign_data {
    return (
        id => 'http://api.constantcontact.com/ws/customers/username/campaigns/1',
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
        FromEmail => 'username@example.com',
        ReplyToEmail => 'username@example.com',
    );
}

# Return a Test::Deep comparator tree for the campaign above.
sub _campaign_cmp {
    my ($cc) = @_;
    return all(
        isa('Email::ConstantContact::Campaign'),
        noclass(superhashof({
            _cc => shallow($cc),
            _campaign_data,
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

    # Campaign data for testing.
    my %campaign_data = _campaign_data;

    # Instantiate CC object.
    my $cc = Email::ConstantContact->new('apikey', 'username', 'password');

    # Instantiate and initialize Campaign object.
    my $campaign = Email::ConstantContact::Campaign->new($cc);
    $campaign->{$_} = $campaign_data{$_} for keys %campaign_data;

    # Call code under test.
    ok( $campaign->save(), 'save() success' );

    # Verify request made via mock UA.
    my $requests = $test->{ua_module}->requests;
    cmp_http_requests(
        $requests,
        [
            {
                method => 'PUT',
                url => 'https://api.constantcontact.com/ws/customers/username/campaigns/1',
                content => xml({
                    xmlns => 'http://www.w3.org/2005/Atom',
                    id => 'http://api.constantcontact.com/ws/customers/username/campaigns/1',
                    title => {
                        type => 'text',
                    },
                    author => {},
                    updated => re(qr/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/),
                    summary => {
                        type => 'text',
                        content => 'Campaign',
                    },
                    content => {
                        type => 'application/vnd.ctct+xml',
                        Campaign => superhashof({
                            xmlns => 'http://ws.constantcontact.com/ns/1.0/',
                            id => [ ( $campaign_data{id} ) x 2 ],
                            ( map { $_ => $campaign_data{$_} } qw(
                                Name Status Date Subject FromName ViewAsWebpage PermissionReminder
                                GreetingSalutation GreetingName GreetingString
                                OrganizationName OrganizationAddress1 OrganizationCity OrganizationState
                                OrganizationCountry OrganizationPostalCode
                                IncludeForwardEmail IncludeSubscribeLink
                                EmailContentFormat EmailContent EmailTextContent
                                FromEmail ReplyToEmail
                            ) ),
                        }),
                    },
                }),
            }
        ],
        "HTTP requests",
    ) or diag(Data::Dumper->Dump([$requests], ['requests']));

    # Verify object.
    cmp_deeply(
        $campaign,
        _campaign_cmp($cc),
        "Email::ConstantContact::Campaign object",
    ) or diag(Data::Dumper->Dump([$campaign], ['campaign']));
}


1;

} # BEGIN
