##
## Scalar::Footnote::Functions - smoke tests
##

use lib 't/lib';
use blib;
use strict;
use warnings;

use Test::More   qw( no_plan );
use Scalar::Util qw( weaken isweak );

BEGIN { use_ok( 'Scalar::Footnote::Functions', qw( get_footnote set_footnote remove_footnote ) ); }
$/ = undef;

## smoke test
{
    my $note = 'note';
    my $t1   = {};
    my $set  = set_footnote( $t1, $note );
    is( $set, $t1, 'set_footnote' );
    is( get_footnote( [] ), undef, 'get_footnote returns undef when no note set' );

    my $get = get_footnote( $t1 );
    is  ( $get, $note,   'get_footnote' );
    isnt( \$get, \$note, 'get_footnote returns a copy of note' );

    $note = undef;
    isnt( get_footnote( $t1 ), undef,   'set_footnote is not bound to original var' );
    is( remove_footnote( $t1 ), 'note', 'remove_footnote' );
    is( remove_footnote( $t1 ), undef,  'remove_footnote again, nothing to remove' );
    is( get_footnote( $t1 ), undef,     'can\'t get_footnote anymore' );
#    $t1 = $get = $set = undef;
}

## nested footnotes
{
    my $t1 = {};
    {
	my $t2 = {};
	set_footnote( $t2, 555 );
	set_footnote( $t1, $t2 );
    }
    my $t2 = get_footnote( $t1 );
    is( get_footnote( $t2 ), 555, 'nested footnotes' );
}

