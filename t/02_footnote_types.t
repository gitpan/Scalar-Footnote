##
## Scalar::Footnote - different types of footnote
##

use lib 't/lib';
use blib;
use strict;
use warnings;

use TestNote1;
use Test::More   qw( no_plan );
use Scalar::Util qw( weaken isweak );

BEGIN { use_ok( 'Scalar::Footnote', qw( get_footnote set_footnote ) ); }
$/ = undef;

## note is const
{
    my $n1 = 'const sv';
    my $t1 = {};
    is( set_footnote( $t1, $n1 ), $t1,   'set_footnote(), note is const sv' );
    is( get_footnote( $t1 ), 'const sv', 'get_footnote(), note is const sv' );
}

## note is scalar ref
{
    my $n1 = 'scalar';
    my $t1 = {};
    is( set_footnote( $t1, \$n1 ), $t1, 'set_footnote(), note is scalar ref' );
    is( ${ get_footnote( $t1 ) }, $n1,  'get_footnote(), note is scalar ref' );
}

## note is array ref
{
    my $n1 = ['array ref'];
    my $t1 = {};
    is( set_footnote( $t1, $n1 ), $t1, 'set_footnote(), note is array ref' );
    is( get_footnote( $t1 ), $n1,      'get_footnote(), note is array ref' );
}

## note is hash ref
{
    my $n1 = { hash => 'ref'};
    my $t1 = {};
    is( set_footnote( $t1, $n1 ), $t1, 'set_footnote(), note is hash ref' );
    is( get_footnote( $t1 ), $n1,      'get_footnote(), note is hash ref' );
}

## note is code ref
{
    my $n1 = sub { 'code ref' };
    my $t1 = {};
    is( set_footnote( $t1, $n1 ), $t1, 'set_footnote(), note is code ref' );
    is( get_footnote( $t1 ), $n1,      'get_footnote(), note is code ref' );
}

## note is object
{
    TestNote1->reset();
    my $n1 = TestNote1->new;
    my $t1 = {};
    my $t2 = $t1;
    is( set_footnote( $t1, $n1 ), $t1, 'set_footnote(t1), note is obj' );
    is( get_footnote( $t1 ), $n1,      'get_footnote(t1), note is obj' );

    # Some of these tests seem redundant, but they were in the Pixie::Info
    # suite, so they remain just in case they were introduced to highlight
    # bugs.  Better to overtest...
    #    -spurkis

    my $t3 = $t1;
    is( get_footnote( $t1 ), $n1, 'get_footnote(t1), note is obj' );
    is( get_footnote( $t2 ), $n1, 'get_footnote(t2), t2==t1' );
    is( get_footnote( $t2 ), $n1, 'get_footnote(t2) again, nothing changed' );
    is( get_footnote( $t3 ), $n1, 'get_footnote(t3), t3==t1' );
    is( get_footnote( $t1 ), $n1, 'get_footnote(t1) again, nothing changed' );
    is( get_footnote( $t1 ), get_footnote( $t1 ), 'get_footnote( t1 ) returns same obj for subsequent calls' );

    weaken( $n1 );
    is( TestNote1->counter, 0, 'no note1 objects destroyed when orig. note weakened' );

    $t1 = $t2 = $t3 = undef;
    ok( !defined( $n1 ),       'note object destroyed when t1 undefined' );
    is( TestNote1->counter, 1, 'double check note object destroyed' );
}

