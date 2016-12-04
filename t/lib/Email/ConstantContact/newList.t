#!/usr/bin/env perl
use strict;
use warnings;

t::lib::Email::ConstantContact::newList->runtests;


BEGIN {
package t::lib::Email::ConstantContact::newList;
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

t::lib::Email::ConstantContact::newList - Unit test the C<< Email::ConstantContact->newList() >> method.

=head1 SYNOPSIS

    # run all tests  
    prove -lv t/lib/Email/ConstantContact/newList.t

    # run single test method
    TEST_METHOD=test_METHOD_NAME prove -lv t/lib/Email/ConstantContact/newList.t

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

# Return XML for a list.
sub _list_xml {
    return <<'END_OF_XML';
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
END_OF_XML
}

# Return ( key => value ) of list data for the list above.
sub _list_data {
    return (
        link => "/ws/customers/username/lists/1",
        id => "http://api.constantcontact.com/ws/customers/username/lists/1",
        OptInDefault => "false",
        Name => "General Interest",
        ShortName => "General Interest",
        DisplayOnSignup => "Yes",
        SortOrder => 1,
    );
}

# Return a Test::Deep comparator tree for the list above.
sub _list_cmp {
    my ($cc) = @_;
    return all(
        isa('Email::ConstantContact::List'),
        noclass(superhashof({
            _cc => shallow($cc),
            _list_data,
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

Test calling newList($name, \%data).

=cut

sub test_smoke : Test(2) {
    my $test = shift;

    # Set Data::Dumper format for diag statements below.
    local $Data::Dumper::Sortkeys = 1;
    local $Data::Dumper::Indent = 1;
    local $Data::Dumper::Useqq = 1;

    # Set XML and HTTP code to be returned from mock HTTP request.
    $test->{ua_module}->response_code( 201 );
    $test->{ua_module}->response_content( _list_xml );

    # List data for testing.
    my %list_data = _list_data;
    my $list_name = delete $list_data{Name};

    # Instantiate CC object.
    my $cc = Email::ConstantContact->new('apikey', 'username', 'password');

    # Call code under test.
    my $list = $cc->newList($list_name, \%list_data);

    # Verify request made via mock UA.
    my $requests = $test->{ua_module}->requests;
    cmp_http_requests(
        $requests,
        [
            {
                method => 'POST',
                url => 'https://api.constantcontact.com/ws/customers/username/lists',
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
                        content => 'ContactList',
                    },
                    content => {
                        type => 'application/vnd.ctct+xml',
                        ContactList => {
                            xmlns => 'http://ws.constantcontact.com/ns/1.0/',
                            OptInDefault => 'false',
                            DisplayOnSignup => 'Yes',
                            Name => 'General Interest',
                            SortOrder => '1',
                        },
                    },
                }),
            }
        ],
        "HTTP requests",
    ) or diag(Data::Dumper->Dump([$requests], ['requests']));

    # Verify activity object returned.
    cmp_deeply(
        $list,
        _list_cmp($cc),
        "Email::ConstantContact::List object",
    ) or diag(Data::Dumper->Dump([$list], ['list']));
}


1;

} # BEGIN
