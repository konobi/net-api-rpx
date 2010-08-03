package Net::API::RPX::Exception::Usage;

# $Id:$
use strict;
use warnings;
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
  return sprintf q{Method %s on package %s expects the parameter "%s"}.qq{\n}.qq{\t%s\n}  , $self->method_name , $self->package , $self->required_parameter, $self->_signature_String;
}

sub full_message {
    my $self = shift;
    my $msg = $self->message . qq{\n} . $self->_explanation;
    return $msg;
}
__PACKAGE__->meta->make_immutable;
1;

