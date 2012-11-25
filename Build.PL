use 5.006;
use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
	module_name          => 'Data::Validate::Type',
	license              => 'GPL_3',
	dist_author          => q{Guillaume Aubert <aubertg@cpan.org>},
	dist_version_from    => 'lib/Data/Validate/Type.pm',
	build_requires       =>
	{
		'File::Spec'            => 0,
		'Test::Exception'       => 0,
		'Test::More'            => 0.94, # Required for subtest().
	},
	requires             =>
	{
		'perl'                  => 5.006,
		'Carp'                  => 0,
		'Data::Dump'            => 0,
		'Exporter'              => 0,
		'Scalar::Util'          => 1.18, # Recent 'looks_like_number'.
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
			repository  => 'https://github.com/guillaumeaubert/Data-Validate-Type',
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
