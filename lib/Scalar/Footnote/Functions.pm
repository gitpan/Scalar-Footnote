=head1 NAME

Scalar::Footnote::Functions - under-the-hood functions for L<Scalar::Footnote>

=head1 SYNOPSIS

  # Don't use this module directly!
  # You should use the Scalar::Footnote API to access footnotes cleanly.

  use Scalar::Footnote::Functions qw( set_footnote get_footnote remove_footnote );

  my $ref = [];

  # attach invisible footnote to $ref:
  set_footnote( $ref, 'footnote' );

  # get it back:
  $footnote = get_footnote( $ref );

  # remove it:
  $footnote = remove_footnote( $ref );

  # or you can do things OO-stylee:
  $obj->Scalar::Footnote::set_footnote( $a_value );
  $note = Scalar::Footnote::get_footnote( $obj );
  $note = $obj->Scalar::Footnote::get_footnote;
  $note = $obj->Scalar::Footnote::remove_footnote;

=cut

package Scalar::Footnote::Functions;

use strict;
use warnings;

require Exporter;
require DynaLoader;
require AutoLoader;

our @ISA       = qw( Exporter DynaLoader );
our @EXPORT    = qw( );
our @EXPORT_OK = qw( get_footnote set_footnote remove_footnote );
our $VERSION   = '0.99_02';

bootstrap Scalar::Footnote::Functions $VERSION;

1;

__END__

=head1 DESCRIPTION

This package contains all the under-the-hood XS code that does all the work
for L<Scalar::Footnote>.  You should never use it directly -- if you start
setting footnotes that aren't C<Scalar::Footnote> objects (or sub-classes)
then things might not work as you might expect... B<you have been warned!>


  my $ref = [qw( foo bar )];
  set_footnote( $ref, { a => 'footnote' } );
  print Dumper( $ref );

prints:

  $VAR1 = [
            'foo',
            'bar'
          ];

If you destroy the $ref and you don't hold a copy of the footnote, it also
gets destroyed:

  my $ref = {};
  set_footnote( $ref, MyFootnote->new );
  $ref = undef; # footnote gets destroyed

As with most subs in Perl, L<set_footnote()> makes a copy of the footnote
scalar you give it (earlier versions didn't).

=head2 What Are Footnotes Attached To?

Footnotes are attached to the referenced value of the $ref you pass in (not
the variable C<$ref> itself).  So in the following:

  my $ref1;
  {
      my $ref2 = {};
      $ref1    = $ref2;
      set_footnote( $ref2, ['a footnote'] );
  }
  print get_footnote( $ref1 );

The footnote is attached to the anonymous hashref, C<{}>, not $ref2.  That's
why you can still access it through $ref1 after $ref2 goes out of scope.

=head2 What Can I Attach Footnotes To?

Pretty much any kind of reference -- scalar refs, hash refs, array refs, and
code refs have been tested.

=head2 What Can I Use As A Footnote?

Pretty much any kind of scalar.  Constants, scalar refs, hash refs, array
refs, and code refs have been tested.

=head1 CAVEATS

Watch out for circular references - L<Scalar::Util>'s weaken() is your friend,
as is L<Data::Structure::Util>'s has_circular_ref() and curcular_off().

=head1 FUNCTIONS

=over 4

=item $ref = set_footnote( $ref, $footnote )

Attaches $footnote to $ref (which B<must> be a reference), and overwrites any
footnotes that were previously attached.  Dies if $ref is not a reference, or
if there was an error.  Returns the $ref on success.

=item $footnote = get_footnote( $ref )

Gets the footnote attached to $ref (which B<must> be a reference).  Dies if
$ref is not a reference, or if there was an error.  Returns the $footnote, or
C<undef> if no footnote was attached.

=item $footnote = remove_footnote( $ref )

Removes the footnote attached to $ref (which B<must> be a reference).  Dies if
$ref is not a reference, or if there was an error.  Returns the removed
$footnote, or C<undef> if no footnote was attached.

=back

=head1 KNOWN BUGS

Attempts to clone objects using L<Clone> dies with:

  Don't know how to handle magic of type \37777777633 at ...

=head1 AUTHORS

M. Friebe, original concept.

Converted to L<Pixie> by Piers Cawley (changed the magic type, module name,
stole the idea).

Converted to Scalar::Footnote by Steve Purkis <spurkis@cpan.org>, updated to
store a copy of the footnote.

=head1 SEE ALSO

L<Scalar::Util>, L<Data::Structure::Util>

=cut
