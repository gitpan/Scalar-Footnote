=head1 NAME

Scalar::Footnote - Attach hidden scalars to references

=head1 SYNOPSIS

  use Data::Dumper;
  use Scalar::Footnote;

  my $obj = Foo->new;

  # attach invisible footnote to $obj:
  $obj->Scalar::Footnote::set( my_key => 'my footnote' );
  print Dumper( $obj );

  # get it back:
  my $note = $obj->Scalar::Footnote::get( 'my_key' );
  print "footnote: $note\n";

  # remove it:
  my $note = $obj->Scalar::Footnote::remove( 'my_key' );

=cut

package Scalar::Footnote;

use strict;
use warnings;

use Carp qw( carp croak confess );
use Scalar::Footnote::Functions qw( get_footnote set_footnote remove_footnote );

our $VERSION = '0.99_02';

sub new {
    my $class = shift;
    my $self  = bless {}, $class;
    $self->init( @_ );
    return $self;
}

sub init { return $_[0]; }

sub set_value_for {
    my $self = shift;
    my $key  = shift;
    $self->{"$key"} = shift;
    return $self;
}

sub get_value_for {
    my $self = shift;
    my $key  = shift;
    $self->{"$key"};
}

sub remove_value_for {
    my $self = shift;
    my $key  = shift;
    delete $self->{"$key"};
}

sub attach_to {
    my $self = shift;
    my $thing = shift;

    croak( "can't set footnote object: '$thing' is not a ref!" ) unless ref( $thing );

    set_footnote( $thing => $self );

    return $self;
}

#-------------------------------------------------------------------------------
# Class Methods
#-------------------------------------------------------------------------------

sub attach_new_footnote_object_to {
    my $class = shift;
    my $thing = shift;
    return Scalar::Footnote->new->attach_to( $thing );
}

sub get_footnote_object_for {
    my $class = shift;
    my $thing = shift;

    confess( "can't get footnote object: '$thing' is not a ref!" ) unless ref( $thing );

    my $note = get_footnote( $thing );

    return unless defined( $note );

    croak( "footnote object for '$thing' is not a Scalar::Footnote object (it's '$note')" )
      unless UNIVERSAL::isa( $note, 'Scalar::Footnote' );

    return $note;
}

sub get_or_create_footnote_object_for {
    my $class = shift;
    my $thing = shift;
    return $class->get_footnote_object_for( $thing ) ||
           $class->attach_new_footnote_object_to( $thing );
}

#-------------------------------------------------------------------------------
# Pseudo Class Methods
#-------------------------------------------------------------------------------

sub set {
    my $thing = shift;
    my $key   = shift;
    my $value = shift;

    croak( "can't set footnote for '$thing' - it's not a ref!" )
      unless ref( $thing );

    my $note = Scalar::Footnote->get_or_create_footnote_object_for( $thing );

    $note->set_value_for( $key => $value );

    return $thing;
}

sub get {
    my $thing = shift;
    my $key   = shift;

    croak( "can't get footnote for '$thing' - it's not a ref!" )
      unless ref( $thing );

    my $note = Scalar::Footnote->get_footnote_object_for( $thing ) || return;

    return $note->get_value_for( $key );
}

sub remove {
    my $thing = shift;
    my $key   = shift;

    croak( "can't remove footnote for '$thing' - it's not a ref!" )
      unless ref( $thing );

    my $note = Scalar::Footnote->get_footnote_object_for( $thing ) || return;

    return $note->remove_value_for( $key );
}

sub remove_all {
    my $thing = shift;

    croak( "can't remove all footnotes for '$thing' - it's not a ref!" )
      unless ref( $thing );

    my $note = remove_footnote( $thing );

    return unless defined( $note );

    carp( "footnote for '$thing' is not a Scalar::Footnote object (it's '$note')" )
      unless UNIVERSAL::isa( $note, 'Scalar::Footnote' );

    return $note;
}

1;

__END__

=head1 DESCRIPTION

C<Scalar::Footnote> lets you attach scalar I<footnotes> to an object (or any
kind of reference, really) that are essentially invisible from Perl.  For
example, if you try dumping an object that has a footnote attached to it, you
won't actually see the footnote:

  my $obj = bless [qw( foo bar )], 'Foo';
  $obj->Scalar::Footnote::set( 'Foo' => 'foo note' );
  print Dumper( $obj );

prints:

  $VAR1 = bless [
            'foo',
            'bar'
          ], 'Foo';

You can of course still access the footnote with L<Scalar::Footnote::get>.

=head2 Footnote Keys

To avoid overwriting footnotes other people have created, you have to specify
a key to store your footnote under.  You should pick something fairly unique,
such as a namespace you're using:

  $obj->Scalar::Footnote::set( 'My::Project' => 'foo note' );

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

=head2 When Are Footnotes Destroyed?

Footnotes go away when the reference they're attached to goes away, unless
you hold a copy of the footnote elsewhere:

  my $ref  = {};
  my $note = bless [qw( bar note )], 'Bar';
  Scalar::Footnote::set( $ref, 'my footnote key' => $note );

  $note = undef;
  # $note is still accessible via Scalar::Footnote::get

  $ref  = undef;
  # $note is now destroyed

=head1 CLASS METHODS / FUNCTIONS

These are not quite class methods, but were intended to be used in an OO style.

=over 4

=item $ref = Scalar::Footnote::set( $ref, $key => $footnote )

Attaches $footnote to $ref (which B<must> be a reference), and overwrites any
footnotes that were previously attached.  Dies if $ref is not a reference, or
if there was an error.  Returns the $ref on success.

=item $footnote = Scalar::Footnote::get( $ref, $key )

Gets the footnote attached to $ref (which B<must> be a reference).  Dies if
$ref is not a reference, or if there was an error.  Returns the $footnote, or
C<undef> if no footnote was attached.

=item $footnote = Scalar::Footnote::remove( $ref, $key )

Removes the footnote attached to $ref (which B<must> be a reference).  Dies if
$ref is not a reference, or if there was an error.  Returns the removed
$footnote, or C<undef> if no footnote was attached.

=item $footnote_obj = Scalar::Footnote::remove_all( $ref )

Removes all footnotes attached to $ref (which B<must> be a reference).  Dies if
$ref is not a reference, or if there was an error.  Returns the removed
C<Scalar::Footnote> object, or C<undef> if no footnote was attached.

=item $footnote_obj = Scalar::Footnote->get_footnote_object_for( $ref )

Returns the C<Scalar::Footnote> object attached to $ref (which B<must> be a
reference) or C<undef> if no footnote was attached.  Dies if $ref is not a
reference, or if there was an error.

=item $footnote_obj = Scalar::Footnote->attach_new_footnote_object_to( $ref )

Creates a new C<Scalar::Footnote> object and attaches it to $ref (which
B<must> be a reference), overwriting any previous footnotes attached.  Dies if
$ref is not a reference, or if there was an error.  Returns the new footnote
object.

=back

=head1 INSTANCE METHODS

These can be used on C<Scalar::Footnote> objects returned by any of the class
methods above.  They return the footnote object unless otherwise specified.

=over 4

=item $footnote_obj->set_value_for( $key => $val )

As in C< $footnotes{$key} = $val >.

=item $val = $footnote_obj->get_value_for( $key )

As in C< $footnotes{$key} >.

=item $val = $footnote_obj->remove_value_for( $key )

As in C< delete $footnotes{$key} >.

=back

=head1 CAVEATS

Watch out for circular references - L<Scalar::Util>'s weaken() is your friend,
as is L<Data::Structure::Util>'s has_circular_ref() and curcular_off().

=head1 KNOWN BUGS

Attempts to clone objects using L<Clone> dies with:

  Don't know how to handle magic of type \37777777633 at ...

=head1 AUTHORS

M. Friebe, original concept.

Converted to L<Pixie> by Piers Cawley (changed the magic type, module name,
stole the idea).

Converted to Scalar::Footnote by Steve Purkis <spurkis@cpan.org>, OO interface
added, updated XS to store a copy of the footnote.

=head1 SEE ALSO

L<Scalar::Util>, L<Data::Structure::Util>

=cut
