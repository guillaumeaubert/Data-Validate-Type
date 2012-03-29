#!perl -T

use strict;
use warnings;

use Test::More tests => 2;
use Data::Validate::Type;


my $variable = LocalTestChild->new();

ok(
	Data::Validate::Type::is_instance(
		$variable,
		class => 'LocalTestChild',
	),
	'The variable is an instance of its class.',
);

ok(
	Data::Validate::Type::is_instance(
		$variable,
		class => 'LocalTestParent',
	),
	'The variable is an instance of its parent class.',
);


package LocalTestParent;

use strict;
use warnings;

sub new
{
	return bless( {}, 'LocalTestParent' );
}

1;

package LocalTestChild;

use strict;
use warnings;

use base 'LocalTestParent';

sub new
{
	return bless( {}, 'LocalTestChild' );
}

1;
