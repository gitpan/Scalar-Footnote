##
## Scalar::Footnote::Functions - test cleanups & overwriting
##

use lib 't/lib';
use blib;
use strict;
use warnings;

use Test::More   qw( no_plan );
use Scalar::Util qw( weaken isweak );

use TestNote1;
use TestNote2;

BEGIN { use_ok( 'Scalar::Footnote::Functions', qw( get_footnote set_footnote remove_footnote ) ); }
$/ = undef;

## refcounts & freeing sv's
{
    my $note = [1];
    my $t1   = {};
    set_footnote( $t1, $note );

    weaken( $note );
    ok( $note, 'set_footnote incs refcount (original var still defined when weakened)' );
    is( get_footnote( $t1 ), $note, 'get_footnote still works when original var weakened' );

    weaken( $t1 );
    ok( !defined( $t1 ),   't1 freed when weakened' );
    ok( !defined( $note ), 'original (weakened) note var also freed' );
}

## remove then re-add
{
    my $t1 = {};
    set_footnote( $t1, 'note1' );
    remove_footnote( $t1 );
    set_footnote( $t1, 'note2' );
    is( get_footnote( $t1 ), 'note2', 'remove / re-add footnote' );
}

## overwrite values
{
    my $note1 = [];
    my $note2 = {};
    my ($t1, $t2) = (undef, 'test 2');
    $t1 = \$t2;

    set_footnote( $t1, $note1 );

    weaken( $note1 );
    set_footnote( $t1, $note2 );

    my $get = get_footnote( $t1 );
    is( $get, $note2,  'set_footnote overwrites old values' );
    is( $note1, undef, 'old value for note is freed' );
}

## overwrite w/objects
{
    reset_counters();
    my $n1 = TestNote1->new;
    my $n2 = TestNote2->new;
    my $t1 = {};

    set_footnote( $t1, $n1 );
    set_footnote( $t1, $n2 );
    is( get_footnote( $t1 ), $n2, 'set_footnote overwrites old objects' );

    is( TestNote1->counter, 0, 'no note1 objects destroyed, n1 in scope' );
    is( TestNote2->counter, 0, 'no note2 objects destroyed, t1 in scope' );
}

is( TestNote1->counter, 1, 'note1 object destroyed, n1 out of scope' );
is( TestNote2->counter, 1, 'note2 object destroyed, t1 out of scope' );

## original note objects out of scope
{
    reset_counters();
    my $t1 = {};
    set_footnote( $t1, TestNote1->new );
    isa_ok( get_footnote( $t1 ), 'TestNote1', 'get_footnote( t1 ), original note out of scope' );
    is( TestNote1->counter, 0, 'no note1 objects destroyed, t1 in scope' );

    set_footnote( $t1, TestNote2->new );
    is( TestNote1->counter, 1, 'note1 object destroyed after over-writing note in t1' );
    is( TestNote2->counter, 0, 'no note2 objects destroyed, t1 in scope' );

    $t1 = undef;
    is( TestNote2->counter, 1, 'note2 object destroyed, t1 out of scope' );
}


#------------------------------------------------------------------------------
# Test Helper Stuff
#------------------------------------------------------------------------------

sub reset_counters {
    TestNote1->reset;
    TestNote2->reset;
}
