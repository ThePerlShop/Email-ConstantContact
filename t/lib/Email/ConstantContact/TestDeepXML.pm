package t::lib::Email::ConstantContact::TestDeepXML;
use strict;
use warnings;

use parent 'Exporter';

our @EXPORT = qw(xml);


use parent 'Test::Deep::Cmp';


use XML::Simple;


=head1 NAME

t::lib::Email::ConstantContact::TestDeepXML - C<Test::Deep> comparator functions
to test XML structurally with C<cmp_deeply>.

=head1 SYNOPSIS

    use t::lib::Email::ConstantContact::TestDeepXML;

    cmp_deeply(
        $xml,
        xml(\%expected_xml_structure),
        'description of test',
    );

=cut


sub xml {
    return __PACKAGE__->new(@_);
}


sub init
{
    my $self = shift;
    $self->{val} = shift;
}

sub descend
{
    my $self = shift;
    my $got = shift;

    my $xml_structure = XMLin($got);
    my $expected = $self->{val};
    return Test::Deep::descend($xml_structure, $expected);
}


1;


1;
