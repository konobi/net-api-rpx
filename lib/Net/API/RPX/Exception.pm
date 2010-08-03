package Net::API::RPX::Exception;

# $Id:$
use strict;
use warnings;

=head1 NAME

Net::API::RPX::Exception - A hackish baseclass fusing L<Moose> with L<Exception::Class>

=cut

=head1 DEBUGGING

For complete backtraces in C<< die() >>, set C<< $ENV{NET_API_RPX_STACKTRACE} = 1 >>

=cut

use Moose;
use MooseX::NonMoose;
extends qw( Exception::Class::Base);

=head1 METHODS

=head2 FOREIGNBUILDARGS

This strips moose meta attributes from the arguement list before passing them
through to the Exception::Class::Base parent class

=cut

sub FOREIGNBUILDARGS {
  my ( $class, %args ) = @_;
  for ( $class->meta->get_attribute_list ) {
    delete $args{$_};
  }
  return %args;
}

around show_trace => sub {
  my ( $orig, $class, @rest ) = @_;
  return 1 if exists $ENV{NET_API_RPX_STACKTRACE} and $ENV{NET_API_RPX_STACKTRACE};
  return $class->$orig(@rest);
};

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;

