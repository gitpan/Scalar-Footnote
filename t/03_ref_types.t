##
## Scalar::Footnote - test attach to different types of ref
##

use lib 't/lib';
use blib;
use strict;
use warnings;

use Test::More   qw( no_plan );
use Scalar::Util qw( weaken isweak );

BEGIN { use_ok( 'Scalar::Footnote', qw( get_footnote set_footnote ) ); }
$/ = undef;

## not a ref
{
    eval{ set_footnote( 'const', 'fail' ) };
    ok( $@, 'set_footnote( const, ...) fails' );

    eval{ set_footnote( undef, 'fail' ) };
    ok( $@, 'set_footnote( undef, ...) fails' );
}

## scalar refs
{
    my $t1 = 'scalar';
    eval{ set_footnote( \$t1, 'pass' ) };
    ok( !$@, 'set_footnote( scalarref, ...) works' );
}

## constant refs (scalar refs that are RO)
{
    eval{ set_footnote( \ 'const', 'pass' ) };
    ok( !$@, 'set_footnote( \ const, ...) works' );
}

## hash refs
{
    eval{ set_footnote( {}, 'pass' ) };
    ok( !$@, 'set_footnote( hashref, ...) works' );
}

## array refs
{
    eval{ set_footnote( [], 'pass' ) };
    ok( !$@, 'set_footnote( arrayref, ...) works' );
}

## undef refs
{
    eval{ set_footnote( \ undef, 'pass' ) };
    ok( !$@, 'set_footnote( \ undef, ...) works' );
}

## code refs
{
    eval{ set_footnote( sub {'test'}, 'pass' ) };
    ok( !$@, 'set_footnote( coderef, ...) works' );
}

## blessed refs
{
    eval{ set_footnote( bless({}, 'TestRef'), 'pass' ) };
    ok( !$@, 'set_footnote( coderef, ...) works' );
}
