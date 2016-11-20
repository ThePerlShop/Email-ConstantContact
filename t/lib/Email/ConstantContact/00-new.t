#!/usr/bin/env perl
use strict;
use warnings;

use Test::Most tests => 1;

use Data::Dumper;

# Use code under test.
use Email::ConstantContact;


## Instantiate the class and confirm that the object was created as expected.
## Uses internal implementation details.
{
    # Set Data::Dumper format for diag statements below.
    local $Data::Dumper::Sortkeys = 1;
    local $Data::Dumper::Indent = 1;
    local $Data::Dumper::Useqq = 1;

    # Test data for instantiation.
    my $apikey = 'ABCDEFG1234567';
    my $username = 'me&company';
    my $username_url_encoded = 'me%26company';
    my $password = 'topsecret!@#$%12345';

    # Call code under test: construct new instance.
    my $cc = Email::ConstantContact->new($apikey, $username, $password);

    # Validate object.
    cmp_deeply(
        $cc,
        all(
            isa('Email::ConstantContact'),
            noclass({
                apikey => $apikey,
                username => $username,
                password => $password,
                cchome => 'https://api.constantcontact.com',
                rooturl => "https://api.constantcontact.com/ws/customers/$username_url_encoded",
            }),
        ),
        "instance constructed with expected data",
    ) or diag(Data::Dumper->Dump([$cc], ['cc']));
}

__END__
