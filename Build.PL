#!/usr/bin/perl

=head1 NAME

Build.PL - Build script generator for L<Scalar::Footnote>

=head1 SYNOPSIS

 perl Build.PL
 ./Build
 ./Build test
 ./Build install

=cut

use strict;
use warnings;

use Module::Build;
use File::Spec::Functions;

my $SUBCLASS_CODE = join( '', <DATA> );

my $build = Module::Build->new
  (
   module_name        => 'Scalar::Footnote',
   dist_version_from  => catfile(qw( lib Scalar Footnote.pm )),
   create_makefile_pl => 'passthrough',
   create_readme      => 1,
   license            => 'perl',
   requires           => {
			  'perl' => '5.8.0',
		         },
   build_requires     => {
			  'Test::More'    => 0.01,
			  'Module::Build' => 0.20,
			  'Scalar::Util'  => 0.01,
		         },
  );

$build->create_build_script;

__END__

=head1 AUTHOR

Steve Purkis <spurkis@cpan.org>

=cut
