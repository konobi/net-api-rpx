package Net::API::RPX::Exception::Usage;

# $Id:$
use strict;
use warnings;

=head1 NAME

Net::API::RPX::Exception::Usage - For when the interface is used wrongly.

=cut

use Moose;
extends 'Net::API::RPX::Exception';

has 'required_parameter' => ( isa => 'Str', is => 'rw', required => 1 );
has 'method_name'        => ( isa => 'Str', is => 'rw', required => 1 );
has 'signature'          => ( isa => 'Str', is => 'rw', required => 1 );
has 'package'            => ( isa => 'Str', is => 'rw', required => 1 );

sub _signature_string {
  my ($self) = @_;
  return $self->method_name . '(' . $self->signature . ')';
}

sub _explanation {
  my ($self) = @_;
  return sprintf q{Method %s on package %s expects the parameter "%s"} . qq{\n\n} . qq{\tUsage:\t%s\n}, $self->method_name, $self->package,
    $self->required_parameter, $self->_signature_string;
}

=head1 METHODS

=head2 full_message

Overrides Exception::Class::Base 's stringification that is applied to the top of the backtrace.

=cut

sub full_message {
  my $self = shift;
  my $msg  = $self->message . qq{\n} . $self->_explanation;
  return $msg;
}
__PACKAGE__->meta->make_immutable( inline_constructor => 0 );
1;

