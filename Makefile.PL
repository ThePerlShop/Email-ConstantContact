use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Email::ConstantContact',
    AUTHOR              => 'Adam Rich <arich@cpan.org>',
    VERSION_FROM        => 'lib/Email/ConstantContact.pm',
    ABSTRACT_FROM       => 'lib/Email/ConstantContact.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
	LICENSE				=> 'perl',
    PREREQ_PM => {
		'XML::Writer' => 0,
		'XML::Simple' => 0,
		'LWP::UserAgent' => 0,
		'Carp' => 0,
		'HTTP::Request' => 0,
		'POSIX' => 0,
		'URI::Escape' => 0,
    },
    TEST_REQUIRES => {
        'Test::Most' => 0,
        'Test::Class' => 0,
        'Test::MockObject' => 0,
        'Test::MockModule' => 0,
    },
    RECURSIVE_TEST_FILES => 1,
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Email-ConstantContact-*' },
);
