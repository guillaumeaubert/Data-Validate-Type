package Data::Validate::Type;

use warnings;
use strict;

use base 'Exporter';

use Carp;
use Data::Dump qw();
use Params::Util qw();

my @boolean_functions_list = qw(
	is_string
	is_arrayref
	is_hashref
	is_coderef
	is_number
);

my @assertion_functions_list = qw(
	assert_string
	assert_arrayref
	assert_hashref
	assert_coderef
	assert_number
);

my @filtering_functions_list = qw(
	filter_string
	filter_arrayref
	filter_hashref
	filter_coderef
	filter_number
);

our @EXPORT_OK =
(
	@boolean_functions_list,
	@assertion_functions_list,
	@filtering_functions_list,
);
our %EXPORT_TAGS =
(
	boolean_tests => \@boolean_functions_list,
	assertions    => \@assertion_functions_list,
	filters       => \@filtering_functions_list,
	all           =>
	[
		@boolean_functions_list,
		@assertion_functions_list,
		@filtering_functions_list,
	],
);


=head1 NAME

Data::Validate::Type - Public interface encapsulating Params::Util to offer data type validation functions that pass PerlCritic.


=head1 VERSION

Version 1.0.1

=cut

our $VERSION = '1.0.1';


=head1 SYNOPSIS

	# Call with explicit package name.
	use Data::Validate::Type;
	if ( Data::Validate::Type::is_string( 'test' ) )
	{
		# ...
	}

	# Import specific functions.
	use Data::Validate::Type qw( is_string );
	if ( is_string( 'test' ) )
	{
		# ...
	}

	# Import functions for a given paradigm.
	use Data::Validate::Type qw( :boolean_tests );
	if ( is_string( 'test' ) )
	{
		# ...
	}


=head1 DESCRIPTION

Params::Util is a wonderful module, but suffers from a few drawbacks:

=over 4

=item * Function names start with an underscore, which is usually used to
indicate private functions.

=item * Function names are uppercase, which is usually used to indicate file
handles or constants.

=item * Function names don't pass PerlCritic's validation, making them
problematic to import.

=item * Functions use by default the convention that collection that collections
need to not be empty to be valid (see _ARRAY0/_ARRAY for example), which is
counter-intuitive.

=back

Those drawbacks are purely cosmetic and don't affect the usefulness of the
functions, so this module encapsulates the functions to offer an API that
fixes these problems.

Please note that I prefer long function names that are descriptive, to arcane
short ones. This increases readability, and the bulk of the typing can be
spared with the use of a good IDE like Padre.

Also, this is work in progress - I haven't encapsulated all the functions from
C<Params::Util> yet, and if you need one in particular feel free to contact me.

=head1 BOOLEAN TEST FUNCTIONS

Functions in this group return a boolean to indicate whether the parameters
passed match the test(s) specified by the functions or not.

All the boolean functions can be imported at once in your namespace with the
following line:

	use Data::Validate::Type qw( :boolean_tests );


=head2 is_string()

Return a boolean indicating if the variable passed is a string.

	my $is_string = Data::Validate::Type::is_string( $variable );

Note: 0 and '' (empty string) are valid strings.

Parameters:

=over 4

=item * allow_empty

Boolean, default 1. Allow the string to be empty or not.

=back

=cut

sub is_string
{
	my ( $variable, %args ) = @_;
	
	# Check parameters.
	my $allow_empty = delete( $args{'allow_empty'} );
	$allow_empty = 1 unless defined( $allow_empty );
	croak 'Arguments not recognized: ' . Data::Dump::dump( %args )
		unless scalar( keys %args ) == 0;
	
	# Check variable.
	return 0 unless defined( $variable );
	
	if ( $variable eq '' )
	{
		return $allow_empty
			? 1
			: 0;
	}
	
	return defined( Params::Util::_STRING( $variable ) ) ? 1 : 0;
}


=head2 is_arrayref()

Return a boolean indicating if the variable passed is an arrayref that can be
dereferenced into an array.

	my $is_arrayref = Data::Validate::Type::is_arrayref( $variable );
	
	my $is_arrayref = Data::Validate::Type::is_arrayref(
		$variable,
		allow_empty => 1,
		no_blessing => 0,
	);

Parameters:

=over 4

=item * allow_empty

Boolean, default 1. Allow the array to be empty or not.

=item * no_blessing

Boolean, default 0. Require that the variable is not blessed.

=back

=cut

sub is_arrayref
{
	my ( $variable, %args ) = @_;
	
	# Check parameters.
	my $allow_empty = delete( $args{'allow_empty'} );
	$allow_empty = 1 unless defined( $allow_empty );
	my $no_blessing = delete( $args{'no_blessing'} ) || 0;
	croak 'Arguments not recognized: ' . Data::Dump::dump( %args )
		unless scalar( keys %args ) == 0;
	
	# Check variable.
	return 0 unless defined( Params::Util::_ARRAYLIKE( $variable ) );
	return 0 if !$allow_empty && scalar( @$variable ) == 0;
	
	# Params::Util has a bug that detects blessed arrays correctly in pure perl
	# mode, but not in default mode. I filed a bug report at
	# https://rt.cpan.org/Ticket/Display.html?id=75561, but until this is fixed
	# we need to handle the no_blessing option manually here.
	return 0 if $no_blessing && ref( $variable ) ne 'ARRAY';
	
	return 1;
}


=head2 is_hashref()

Return a boolean indicating if the variable passed is a hashref that can be
dereferenced into a hash.

	my $is_hashref = Data::Validate::Type::is_hashref( $variable );
	
	my $is_hashref = Data::Validate::Type::is_hashref(
		$variable,
		allow_empty => 1,
		no_blessing => 0,
	);

Parameters:

=over 4

=item * allow_empty

Boolean, default 1. Allow the array to be empty or not.

=item * no_blessing

Boolean, default 0. Require that the variable is not blessed.

=back
	
=cut

sub is_hashref
{
	my ( $variable, %args ) = @_;
	
	# Check parameters.
	my $allow_empty = delete( $args{'allow_empty'} );
	$allow_empty = 1 unless defined( $allow_empty );
	my $no_blessing = delete( $args{'no_blessing'} ) || 0;
	croak 'Arguments not recognized: ' . Data::Dump::dump( %args )
		unless scalar( keys %args ) == 0;
	
	# Check variable.
	return 0 unless defined( Params::Util::_HASHLIKE( $variable ) );
	return 0 if !$allow_empty && scalar( keys %$variable ) == 0;
	
	# Params::Util has a bug that detects blessed hashes correctly in pure perl
	# mode, but not in default mode. Until this is fixed we need to handle the
	# no_blessing option manually here.
	return 0 if $no_blessing && ref( $variable ) ne 'HASH';
	
	return 1;
}


=head2 is_coderef()

Return a boolean indicating if the variable passed is an coderef that can be
dereferenced into a block of code.

	my $is_coderef = Data::Validate::Type::is_coderef( $variable );

=cut

sub is_coderef
{
	my ( $variable, %args ) = @_;
	
	# Check parameters.
	croak 'Arguments not recognized: ' . Data::Dump::dump( %args )
		unless scalar( keys %args ) == 0;
	
	# Check variable.
	return defined( Params::Util::_CODE( $variable ) ) ? 1 : 0;
}


=head2 is_number()

Return a boolean indicating if the variable passed is a number.

	my $is_number = Data::Validate::Type::is_number( $variable );
	my $is_number = Data::Validate::Type::is_number(
		$variable,
		positive => 1,
	);
	my $is_number = Data::Validate::Type::is_number(
		$variable,
		strictly_positive => 1,
	);

Parameters:

=over 4

=item * strictly_positive

Boolean, default 0. Set to 1 to check for a strictly positive number.

=item * positive

Boolean, default 0. Set to 1 to check for a positive number.

=back

=cut

sub is_number
{
	my ( $variable, %args ) = @_;
	
	# Check parameters.
	my $positive = delete( $args{'positive'} ) || 0;
	my $strictly_positive = delete( $args{'strictly_positive'} ) || 0;
	croak 'Arguments not recognized: ' . Data::Dump::dump( %args )
		unless scalar( keys %args ) == 0;
	
	# On Perl 5.8, when using the non-PP version of Params::Util,
	# Params::Util::_NUMBER() identifies strings (empty or not) as numbers.
	# This seems to be a problem deep in perl.h with the sv* flags, but
	# since 5.8 is old I'm simply using the following workaround which
	# appears to force reset the flags for scalars only
	# (found after quite a bit of experimentation).
	$variable = '' . $variable
		if ( !$^V || $^V lt v5.9.0 ) && is_string( $variable );
	
	# Check variable.
	return 0 unless defined( Params::Util::_NUMBER( $variable ) );
	return 0 if $positive && $variable < 0;
	return 0 if $strictly_positive && $variable <= 0;
	
	return 1;
}


=head1 ASSERTION-BASED FUNCTIONS

Functions in this group do not return anything, but will die when the parameters
passed don't match the test(s) specified by the functions.

All the assertion test functions can be imported at once in your namespace with
the following line:

	use Data::Validate::Type qw( :assertions );


=head2 assert_string()

Die unless the variable passed is a string.

	Data::Validate::Type::assert_string( $variable );

Note: 0 and '' (empty string) are valid strings.

Parameters:

=over 4

=item * allow_empty

Boolean, default 1. Allow the string to be empty or not.

=back

=cut

sub assert_string
{
	my ( $variable, %args ) = @_;
	
	croak 'Not a string'
		unless is_string( $variable, %args );
	
	return;
}


=head2 assert_arrayref()

Die unless the variable passed is an arrayref that can be dereferenced into an
array.

	Data::Validate::Type::assert_arrayref( $variable );
	
	Data::Validate::Type::assert_arrayref(
		$variable,
		allow_empty => 1,
		no_blessing => 0,
	);

Parameters:

=over 4

=item * allow_empty

Boolean, default 1. Allow the array to be empty or not.

=item * no_blessing

Boolean, default 0. Require that the variable is not blessed.

=back

=cut

sub assert_arrayref
{
	my ( $variable, %args ) = @_;
	
	croak 'Not an arrayref'
		unless is_arrayref( $variable, %args );
	
	return;
}


=head2 assert_hashref()

Die unless the variable passed is a hashref that can be dereferenced into a hash.

	Data::Validate::Type::assert_hashref( $variable );
	
	Data::Validate::Type::assert_hashref(
		$variable,
		allow_empty => 1,
		no_blessing => 0,
	);

Parameters:

=over 4

=item * allow_empty

Boolean, default 1. Allow the array to be empty or not.

=item * no_blessing

Boolean, default 0. Require that the variable is not blessed.

=back
	
=cut

sub assert_hashref
{
	my ( $variable, %args ) = @_;
	
	croak 'Not a hashref'
		unless is_hashref( $variable, %args );
	
	return;
}


=head2 assert_coderef()

Die unless the variable passed is an coderef that can be dereferenced into a
block of code.

	Data::Validate::Type::assert_coderef( $variable );

=cut

sub assert_coderef
{
	my ( $variable, %args ) = @_;
	
	croak 'Not a coderef'
		unless is_coderef( $variable, %args );
	
	return;
}


=head2 assert_number()

Die unless the variable passed is a number.

	Data::Validate::Type::assert_number( $variable );
	Data::Validate::Type::assert_number(
		$variable,
		positive => 1,
	);
	Data::Validate::Type::assert_number(
		$variable,
		strictly_positive => 1,
	);

Parameters:

=over 4

=item * strictly_positive

Boolean, default 0. Set to 1 to check for a strictly positive number.

=item * positive

Boolean, default 0. Set to 1 to check for a positive number.

=back

=cut

sub assert_number
{
	my ( $variable, %args ) = @_;
	
	croak 'Not a number'
		unless is_number( $variable, %args );
	
	return;
}


=head1 FILTERING FUNCTIONS

Functions in this group return the variable tested against when it matches the
test(s) specified by the functions.

All the filtering functions can be imported at once in your namespace with the
following line:

	use Data::Validate::Type qw( :filters );


=head2 filter_string()

Return the variable passed if it is a string, otherwise return undef.

	Data::Validate::Type::filter_string( $variable );

Note: 0 and '' (empty string) are valid strings.

Parameters:

=over 4

=item * allow_empty

Boolean, default 1. Allow the string to be empty or not.

=back

=cut

sub filter_string
{
	my ( $variable, %args ) = @_;
	
	return is_string( $variable, %args )
		? $variable
		: undef;
}


=head2 filter_arrayref()

Return the variable passed if it is an arrayref that can be dereferenced into an
array, otherwise undef.

	Data::Validate::Type::filter_arrayref( $variable );
	
	Data::Validate::Type::filter_arrayref(
		$variable,
		allow_empty => 1,
		no_blessing => 0,
	);

Parameters:

=over 4

=item * allow_empty

Boolean, default 1. Allow the array to be empty or not.

=item * no_blessing

Boolean, default 0. Require that the variable is not blessed.

=back

=cut

sub filter_arrayref
{
	my ( $variable, %args ) = @_;
	
	return is_arrayref( $variable, %args )
		? $variable
		: undef;
}


=head2 filter_hashref()

Return the variable passed if it is a hashref that can be dereferenced into a
hash, otherwise return undef.

	Data::Validate::Type::filter_hashref( $variable );
	
	Data::Validate::Type::filter_hashref(
		$variable,
		allow_empty => 1,
		no_blessing => 0,
	);

Parameters:

=over 4

=item * allow_empty

Boolean, default 1. Allow the array to be empty or not.

=item * no_blessing

Boolean, default 0. Require that the variable is not blessed.

=back
	
=cut

sub filter_hashref
{
	my ( $variable, %args ) = @_;
	
	return is_hashref( $variable, %args )
		? $variable
		: undef;
}


=head2 filter_coderef()

REturn the variable passed if it is a coderef that can be dereferenced into a
block of code, otherwise return undef.

	Data::Validate::Type::filter_coderef( $variable );

=cut

sub filter_coderef
{
	my ( $variable, %args ) = @_;
	
	return is_coderef( $variable, %args )
		? $variable
		: undef;
}


=head2 filter_number()

Return the variable passed if it is a number, otherwise return undef.

	Data::Validate::Type::filter_number( $variable );
	Data::Validate::Type::filter_number(
		$variable,
		positive => 1,
	);
	Data::Validate::Type::filter_number(
		$variable,
		strictly_positive => 1,
	);

Parameters:

=over 4

=item * strictly_positive

Boolean, default 0. Set to 1 to check for a strictly positive number.

=item * positive

Boolean, default 0. Set to 1 to check for a positive number.

=back

=cut

sub filter_number
{
	my ( $variable, %args ) = @_;
	
	return is_number( $variable, %args )
		? $variable
		: undef;
}


=head1 AUTHOR

Guillaume Aubert, C<< <aubertg at cpan.org> >>.


=head1 BUGS

Please report any bugs or feature requests to C<bug-data-validate-type at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Data-Validate-Type>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

	perldoc Data::Validate::Type


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Data-Validate-Type>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Data-Validate-Type>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Data-Validate-Type>

=item * Search CPAN

L<http://search.cpan.org/dist/Data-Validate-Type/>

=back


=head1 COPYRIGHT & LICENSE

Copyright 2012 Guillaume Aubert.

This program is free software; you can redistribute it and/or modify it
under the terms of the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1;
