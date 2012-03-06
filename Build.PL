use 5.006;
use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
	module_name          => 'Data::Validate::Type',
	license              => 'artistic',
	dist_author          => q{Guillaume Aubert <aubertg@cpan.org>},
	dist_version_from    => 'lib/Data/Validate/Type.pm',
	build_requires       =>
	{
		'Carp'                  => 0,
		'Data::Dumper'          => 0,
		'File::Spec'            => 0,
		'Test::Exception'       => 0,
		'Test::More'            => 0.94, # Required for subtest().
		'Params::Util'          => 1.00, # Stable versions only.
	},
	requires             =>
	{
		'perl'         => 5.006,
	},
	add_to_cleanup       =>
	[
		'Data-Validate-Type-*',
	],
	create_makefile_pl   => 'traditional',
	recursive_test_files => 1,
	configure_requires   =>
	{
		'Module::Build'         => 0,
	},
	meta_merge           =>
	{
		resources               =>
		{
			repository  => 'https://sourceforge.net/p/perldatatype/code',
			homepage    => 'https://metacpan.org/release/Data-Validate-Type',
			bugtracker  => 'http://rt.cpan.org/NoAuth/ReportBug.html?Queue=data-validate-type',
		},
		no_index                =>
		{
			file        =>
			[
				't/LocalTest.pm',
			],
		},
	},
);

$builder->create_build_script();
