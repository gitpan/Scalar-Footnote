=head1 NAME

Scalar::Footnote - Attach hidden scalars to references

=head1 SYNOPSIS

  use Scalar::Footnote qw( set_footnote get_footnote remove_footnote );

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

package Scalar::Footnote;

use strict;

require Exporter;
require DynaLoader;
require AutoLoader;

our @ISA       = qw( Exporter DynaLoader );
our @EXPORT    = qw( );
our @EXPORT_OK = qw( get_footnote set_footnote remove_footnote );
our $VERSION   = '0.99_01';

bootstrap Scalar::Footnote $VERSION;

1;

__END__

=head1 DESCRIPTION

C<Scalar::Footnote> lets you attach a scalar to an object (or any kind of
reference, really).  This scalar I<footnote> is invisible from Perl for all
intents and purposes, so for example, if you try dumping an object that has
a footnote attached then you won't see it:

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

=head1 AUTHORS

M. Friebe, original concept.

Converted to L<Pixie> by Piers Cawley (changed the magic type, module name,
stole the idea).

Converted to Scalar::Footnote by Steve Purkis <spurkis@cpan.org>, updated to
store a copy of the footnote.

=head1 SEE ALSO

L<Scalar::Util>, L<Data::Structure::Util>

=cut
