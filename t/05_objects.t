##
## Scalar::Footnote - OO wrapper
##

use lib 't/lib';
use blib;
use strict;
use warnings;

use Test::More qw( no_plan );

BEGIN { use_ok( 'Scalar::Footnote' ) }

## basic OO stuff
{
    my $note = Scalar::Footnote->new;

    isa_ok( $note, 'Scalar::Footnote', 'new footnote' );

    is( $note->set_value_for( 'my key' => 'my val' ), $note, 'set_value_for' );
    is( $note->get_value_for( 'my key' ), 'my val',          'get_value_for' );
    is( $note->remove_value_for( 'my key' ), 'my val',       'remove_value_for' );
}

## class methods
{
    my $obj  = bless { foo => 'bar' }, 'Foo';
    my $ret  = $obj->Scalar::Footnote::set( 'my key' => 'a value' );
    my $note = Scalar::Footnote::get_footnote( $obj );
    is( $ret, $obj, 'obj->set(key)' );
    isa_ok( $note, 'Scalar::Footnote',               ' attaches new footnote' );
    is( $note->get_value_for( 'my key' ), 'a value', ' sets value for key' );

    my $val = $obj->Scalar::Footnote::get( 'my key' );
    is( $val, 'a value', 'obj->get(key)' );

    is( $obj->Scalar::Footnote::remove( 'my key' ), 'a value', 'obj->remove(key)' );
    is( $obj->Scalar::Footnote::get( 'my key' ), undef,        ' cant get anymore' );
}

## remove all notes
{
    my $obj  = bless { foo => 'bar' }, 'Foo';
    $obj->Scalar::Footnote::set( key1 => 'remove1' )
        ->Scalar::Footnote::set( key2 => 'remove2' );
    my $note = $obj->Scalar::Footnote::remove_all;
    isa_ok( $note, 'Scalar::Footnote', 'obj->remove_all' );
    is( $note->get_value_for( 'key2' ), 'remove2', ' expected contents' );
}

