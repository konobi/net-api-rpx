package Net::API::RPX::Exception::Service;

# $Id:$
use strict;
use warnings;
use Moose;
use namespace::autoclean;

extends 'Net::API::RPX::Exception';

=head1 NAME

Net::API::RPX::Exception::Service - A Class of exceptions for delivering problems from the RPX service.

=cut

my $rpx_errors = {
  -1 => 'Service Temporarily Unavailable',
  0  => 'Missing parameter',
  1  => 'Invalid parameter',
  2  => 'Data not found',
  3  => 'Authentication error',
  4  => 'Facebook Error',
  5  => 'Mapping exists',
};

has 'data'          => ( isa => 'Any', is => 'ro', required => 1 );
has 'status'        => ( isa => 'Any', is => 'ro', required => 1 );
has 'rpx_error'         => ( isa => 'Any', is => 'ro', required => 1 );
has 'rpx_error_code'    => ( isa => 'Any', is => 'ro', required => 1 );
has 'rpx_error_message' => ( isa => 'Any', is => 'ro', required => 1 );
has
  'rpx_error_code_description' => ( isa => 'Any', is => 'ro', required => 1, lazy => 1, ),
  , builder => '_build_rpx_error_code_description';

sub _build_rpx_error_code_description {
  my ($self) = shift;
  return $rpx_errors->{ $self->rpx_error_code };
}
__PACKAGE__->meta->make_immutable();
1;

