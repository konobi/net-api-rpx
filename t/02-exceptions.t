
use strict;
use warnings;

use Test::More tests => 38;    # last test to print
use mocked [ 'LWP::UserAgent', 't/mock' ];
use Net::API::RPX;
use Data::Dump qw( dump );

sub capture(&) {
  my ($code) = shift;
  my ( $result, $evalerror ) = ( 'fail', );
  local $@;
  eval { $code->(); $result = 'test_success' };
  $evalerror = $@;
  if ( defined $result && $result eq 'test_success' ) {
    return ( 1, undef );
  }
  return ( 0, $evalerror );
}
Auth_Info: {
  my ( $result, $error ) = capture {
    Net::API::RPX->new( { api_key => 'test' } )->auth_info( {} );
  };
  ok( !$result, 'expected auth_info fail' );
  isa_ok( $error, 'Net::API::RPX::Exception' );
  isa_ok( $error, 'Net::API::RPX::Exception::Usage' );
  is( $error->message,            'Token is required', '->message' );
  is( $error->method_name,        '->auth_info',       '->method_name' );
  is( $error->package,            'Net::API::RPX',     '->package' );
  is( $error->required_parameter, 'token',             '->required_parameter' );

  # 7;
  ( $result, $error ) = capture {
    $HTTP::Response::CONTENT = '{ "stat": "ok" }';
    Net::API::RPX->new( { api_key => 'test' } )->auth_info( { token => 'foo' } );
  };
  ok( $result, 'no auth_info fail' );

  # 8
}

Map: {

  my ( $result, $error ) = capture {
    Net::API::RPX->new( { api_key => 'test' } )->map( {} );
  };
  ok( !$result, 'expected map fail' );
  isa_ok( $error, 'Net::API::RPX::Exception' );
  isa_ok( $error, 'Net::API::RPX::Exception::Usage' );
  is( $error->message,            'Identifier is required', '->message' );
  is( $error->method_name,        '->map',                  '->method_name' );
  is( $error->package,            'Net::API::RPX',          '->package' );
  is( $error->required_parameter, 'identifier',             '->required_parameter' );
  ( $result, $error ) = capture {
    Net::API::RPX->new( { api_key => 'test' } )->map( { identifier => 'fred' } );
  };
  ok( !$result, 'expected map fail' );
  isa_ok( $error, 'Net::API::RPX::Exception' );
  isa_ok( $error, 'Net::API::RPX::Exception::Usage' );
  is( $error->message,            'Primary Key is required', '->message' );
  is( $error->method_name,        '->map',                   '->method_name' );
  is( $error->package,            'Net::API::RPX',           '->package' );
  is( $error->required_parameter, 'primary_key',             '->required_parameter' );
  ( $result, $error ) = capture {
    $HTTP::Response::CONTENT = '{ "stat": "ok" }';
    Net::API::RPX->new( { api_key => 'test' } )->map( { identifier => 'fred', primary_key => 12 } );
  };
  ok( $result, 'map shouldn\'t fail' );

}

Unmap: {

  my ( $result, $error ) = capture {
    Net::API::RPX->new( { api_key => 'test' } )->unmap( {} );
  };
  ok( !$result, 'expected unmap fail' );
  isa_ok( $error, 'Net::API::RPX::Exception' );
  isa_ok( $error, 'Net::API::RPX::Exception::Usage' );
  is( $error->message,            'Identifier is required', '->message' );
  is( $error->method_name,        '->unmap',                '->method_name' );
  is( $error->package,            'Net::API::RPX',          '->package' );
  is( $error->required_parameter, 'identifier',             '->required_parameter' );
  ( $result, $error ) = capture {
    Net::API::RPX->new( { api_key => 'test' } )->unmap( { identifier => 'fred' } );
  };
  ok( !$result, 'expected unmap fail' );
  isa_ok( $error, 'Net::API::RPX::Exception' );
  isa_ok( $error, 'Net::API::RPX::Exception::Usage' );
  is( $error->message,            'Primary Key is required', '->message' );
  is( $error->method_name,        '->unmap',                 '->method_name' );
  is( $error->package,            'Net::API::RPX',           '->package' );
  is( $error->required_parameter, 'primary_key',             '->required_parameter' );
  ( $result, $error ) = capture {
    $HTTP::Response::CONTENT = '{ "stat": "ok" }';
    Net::API::RPX->new( { api_key => 'test' } )->unmap( { identifier => 'fred', primary_key => 12 } );
  };
  ok( $result, 'unmap shouldn\'t fail' );

}
