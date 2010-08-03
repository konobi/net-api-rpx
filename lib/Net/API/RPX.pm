package Net::API::RPX;

use Moose;
use LWP::UserAgent;
use URI;
use JSON::Any;
use Net::API::RPX::Exception::Usage;
use Net::API::RPX::Exception::Network;
use Net::API::RPX::Exception::Service;

=head1 NAME

Net::API::RPX - Perl interface to Janrain's RPX service

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

has api_key => (
    is => 'rw',
    isa => 'Str',
    required => 1,
);

has base_url => (
    is => 'rw',
    isa => 'Str',
    required => 1,
    lazy => 1,
    default => 'https://rpxnow.com/api/v2/',
);

has ua => (
    is => 'rw',
    isa => 'Object',
    required => 1,
    lazy => 1,
    builder => '_build_ua',
);

sub _build_ua {
    my ($self) = @_;
    return LWP::UserAgent->new(agent => $self->_agent_string);
}

has _agent_string => (
    is => 'rw',
    isa => 'Str',
    required => 1,
    lazy => 1,
    default => sub { "net-api-rpx-perl/$VERSION" },
);

=head1 SYNOPSIS

    use Net::API::RPX;

    my $rpx = Net::API::RPX->new({ api_key => '<your_api_key_here>' });

    $rpx->auth_info({ token => $token });

=head1 DESCRIPTION

This module is a simple wrapper around Janrain's RPX service. RPX provides a single method for
dealing with third-party authentication.

See L<http://www.rpxnow.com> for more details.

For specific information regarding the RPX API and method arguments, please refer to
L<https://rpxnow.com/docs>.

=head1 ATTRIBUTES

This is a Moose based module, this classes attribtues are as so:

=head2 api_key

This is the api_key provided by Janrain to interface with RPX. You will need to signup to RPX
to get one of these.

=head2 base_url

This is the base URL that is used to make API calls against. It defaults to the RPX v2 API.

=head2 ua

This is a LWP::UserAgent object. You may override it if you require more fine grain control
over remote queries.

=head1 METHODS

=head2 auth_info

    my $user_data = $rpx->auth_info({ token => $params{token} });

Upon redirection back from RPX, you will be supplied a token to use for verification. Call
auth_info to verify the authenticity of the token and gain user details.

'token' argument is required, 'extended' argument is optional.

=cut

sub auth_info {
  my ( $self, $opts ) = @_;
  Net::API::RPX::Exception::Usage->throw(
    message            => "Token is required",
    required_parameter => 'token',
    method_name        => '->auth_info',
    package            => __PACKAGE__,
    signature          => '{ token => $authtoken }',
  ) if !exists $opts->{token};
  return $self->_fetch( 'auth_info', $opts );
}

=head2 map

    $rpx->map({ identifier => 'yet.another.open.id', primary_key => 12 });

This method allows you to map more than one 'identifier' to a user.

'identifier' argument is required, 'primary_key' argument is required, 'overwrite' is optional.

=cut

sub map {
  my ($self, $opts) = @_;
  Net::API::RPX::Exception::Usage->throw(
    message => "Identifier is required",
    required_parameter => 'identifier',
    method_name => '->map',
    package => __PACKAGE__,
    signature  => '{ identifier => \'some.open.id\', primary_key => 12 }',
  ) if !exists $opts->{identifier};

   Net::API::RPX::Exception::Usage->throw(
    message => "Primary Key is required",
    required_parameter => 'primary_key',
    method_name => '->map',
    package => __PACKAGE__,
    signature  => '{ identifier => \'some.open.id\', primary_key => 12 }',
  ) if !exists $opts->{primary_key};
  $opts->{primaryKey} = delete $opts->{primary_key};

  return $self->_fetch('map', $opts);
}

=head2 unmap

    $rpx->unmap({ identifier => 'yet.another.open.id', primary_key => 12 });

This is the inverse of 'map'.

'identifier' argument is required, 'primary_key' argument is required.

=cut

sub unmap {
  my ($self, $opts) = @_;
  Net::API::RPX::Exception::Usage->throw(
    message => "Identifier is required",
    required_parameter => 'identifier',
    method_name => '->unmap',
    package => __PACKAGE__,
    signature  => '{ identifier => \'some.open.id\', primary_key => 12 }',
  ) if !exists $opts->{identifier};

   Net::API::RPX::Exception::Usage->throw(
    message => "Primary Key is required",
    required_parameter => 'primary_key',
    method_name => '->unmap',
    package => __PACKAGE__,
    signature  => '{ identifier => \'some.open.id\', primary_key => 12 }',
  ) if !exists $opts->{primary_key};

  $opts->{primaryKey} = delete $opts->{primary_key};

  return $self->_fetch('unmap', $opts);
}

=head2 mappings

    my $data = $rpx->mappings({ primary_key => 12 });

This method returns information about the identifiers associated with a user.

'primary_key' argument is required.

=cut

sub mappings {
  my ($self, $opts) = @_;
  Net::API::RPX::Exception::Usage->throw(
    message => "Primary Key is required",
    required_parameter => 'primary_key',
    method_name => '->mappings',
    package => __PACKAGE__,
    signature  => '{ primary_key => 12 }',
  ) if !exists $opts->{primary_key};

  $opts->{primaryKey} = delete $opts->{primary_key};

  return $self->_fetch('mappings', $opts);
}

my $rpx_errors = {
  -1 => 'Service Temporarily Unavailable',
  0 => 'Missing parameter',
  1 => 'Invalid parameter',
  2 => 'Data not found',
  3 => 'Authentication error',
  4 => 'Facebook Error',
  5 => 'Mapping exists',
};

sub _fetch {
  my ($self, $uri_part, $opts) = @_;

  my $uri = URI->new($self->base_url . $uri_part);
  my $res = $self->ua->post($uri, {
    %$opts,
    apiKey => $self->api_key,
    format => 'json',
  });

  if(!$res->is_success){
    Net::API::RPX::Exception::Network->throw(
        message =>  "Could not contact RPX: " . $res->status_line(),
        ua_result => $res,
        status_line => $res->status_line,
    );
  }

  my $data = JSON::Any->from_json( $res->content );
  if($data->{'stat'} ne 'ok'){
    my $err = $data->{'err'};
    Net::API::RPX::Exception::Service->throw(
        data => $data,
        status => $data->{'stat'},
        rpx_error => $data->{'err'},
        rpx_error_code => $data->{err}->{code},
        rpx_error_message => $data->{err}->{msg},
        message => "RPX returned error of type '". $rpx_errors->{ $err->{code} } . "' with message: " . $err->{msgt},
    );
  }
  delete $data->{'stat'};
  return $data;
}

=head1 TEST COVERAGE

This distribution is heavily unit and system tested for compatability with
L<Test::Builder>. If you come across any bugs, please send me or submit failing
tests to Net-API-RPX RT queue. Please see the 'SUPPORT' section below on
how to supply these.

 ---------------------------- ------ ------ ------ ------ ------ ------ ------
 File                           stmt   bran   cond    sub    pod   time  total
 ---------------------------- ------ ------ ------ ------ ------ ------ ------
 blib/lib/Net/API/RPX.pm       100.0  100.0    n/a  100.0  100.0  100.0  100.0
 Total                         100.0  100.0    n/a  100.0  100.0  100.0  100.0
 ---------------------------- ------ ------ ------ ------ ------ ------ ------


=head1 AUTHOR

Scott McWhirter, C<< <konobi at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-net-api-rpx at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Net-API-RPX>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Net::API::RPX


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Net-API-RPX>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Net-API-RPX>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Net-API-RPX>

=item * Search CPAN

L<http://search.cpan.org/dist/Net-API-RPX>

=back

=head1 SEE ALSO

L<http://www.janrain.com/>, L<http://www.rpxnow.com/>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Cloudtone Studios, all rights reserved.

This program is released under the following license: BSD. Please see the LICENSE file included in this distribution for details.

=cut

1; # End of Net::API::RPX
