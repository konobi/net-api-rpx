package Net::API::RPX::Exception::Network;

# $Id:$
use strict;
use warnings;
use Moose;
use namespace::autoclean;

extends 'Net::API::RPX::Exception';

has 'ua_result'   => ( isa => "Ref", is => 'ro', required => 1 );
has 'status_line' => ( isa => "Str", is => 'ro', required => 1 );

1;

