package t::lib::Email::ConstantContact::MockUserAgent;
use strict;
use warnings;

use parent 'Test::MockModule';

use Test::MockObject;


=head1 NAME

t::lib::Email::ConstantContact::MockUserAgent - C<Test::MockModule> subclass
that mocks methods in C<LWP::UserAgent> for unit-testing
C<Email::ConstantContact> methods.

=head1 SYNOPSIS

    use t::lib::Email::ConstantContact::MockUserAgent;

    $ua_module = t::lib::Email::ConstantContact::MockUserAgent->new();

    # Each call to request() will return one response.
    $ua_module->response_content($content1, $content2, $content3);

    # Clear record of calls to request() before code under test.
    $ua_module->clear_requests();

    LWP::UserAgent->request($req); # usually in code under test

    # A list of HTTP::Request objects passed to request() one for each call.
    cmp_deeply($ua_module->requests, []);

    # Mocked request() will revert to real method when $ua is destroyed.

=cut


sub new {
    my $class = shift;

    my $self = $class->SUPER::new('LWP::UserAgent');

    # private data used by this module
    $self->{_ua} //= {
        response_content => [],
        response_code => [],
        requests => [],
    };

    # mock LWP::UserAgent->request()
    $self->mock( request => sub {
        my $ua = shift; # actual LWP::UserAgent object
        my ($request) = @_;
        push @{$self->{_ua}->{requests}}, $request;

        # mock HTTP response
        my $content = shift @{$self->{_ua}->{response_content}} || '';
        my $code = shift @{$self->{_ua}->{response_code}} || ( $content ? 200 : 404 );
        my $response = Test::MockObject->new();
        $response->set_always( code => $code );
        $response->set_always( status_line => "$code" );
        $response->set_always( content => $content );
        $response->set_always( is_success => 1 );
        return $response;
    } );

    return $self;
}


sub response_content {
    my $self = shift;
    $self->{_ua}->{response_content} = [ @_ ] if @_;
    return $self->{_ua}->{response_content};
}


sub response_code {
    my $self = shift;
    $self->{_ua}->{response_code} = [ @_ ] if @_;
    return $self->{_ua}->{response_code};
}


sub requests {
    my $self = shift;
    return $self->{_ua}->{requests};
}


sub clear_requests {
    my $self = shift;
    $self->{_ua}->{requests} = [];
}


1;
