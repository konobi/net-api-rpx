package Net::API::RPX::Exception::Network;

# $Id:$
use strict;
use warnings;
use Moose;
use namespace::autoclean;

=head1 NAME

Net::API::RPX::Exception::Network - A Class of exceptions for network connectivitiy issues.

=cut

extends 'Net::API::RPX::Exception';

has 'ua_result'   => ( isa => "Ref", is => 'ro', required => 1 );
has 'status_line' => ( isa => "Str", is => 'ro', required => 1 );

__PACKAGE__->meta->make_immutable;
1;

