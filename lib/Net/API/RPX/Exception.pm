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
extends qw( Exception::Class::Base Moose::Object );

around new => sub {
  my ( $orig, $class, @args ) = @_;
  my @mooseargs;
looper: {
    for my $i ( 0 .. $#args / 2 ) {
      my ($key) = $args[ $i * 2 ];
      if ( $class->meta->has_attribute($key) ) {
        push @mooseargs, splice @args, $i * 2, 2, ();
        redo looper;
      }
    }
  }
  my $obj = $class->$orig(@args);
  my $mob = $class->meta->new_object(
    __INSTANCE__ => $obj,
    @mooseargs,
  );
  $mob->show_trace(1) if exists $ENV{NET_API_RPX_STACKTRACE} and $ENV{NET_API_RPX_STACKTRACE};
  return $mob;
};
__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;

