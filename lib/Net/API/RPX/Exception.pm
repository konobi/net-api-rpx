package Net::API::RPX::Exception;

# $Id:$
use strict;
use warnings;

=head1 NAME

Net::API::RPX::Exception - A hackish baseclass fusing L<Moose> with L<Exception::Class>

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
  return $class->meta->new_object(
    __INSTANCE__ => $obj,
    @mooseargs,
  );
};
__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;

