#!perl -T

use Test::More tests => 1;

BEGIN
{
	use_ok( 'Data::Validate::Type' );
}

diag( "Testing Data::Validate::Type $Data::Validate::Type::VERSION, Perl $], $^X" );
