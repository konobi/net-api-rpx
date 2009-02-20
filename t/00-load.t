#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Net::API::RPX' );
}

diag( "Testing Net::API::RPX $Net::API::RPX::VERSION, Perl $], $^X" );
