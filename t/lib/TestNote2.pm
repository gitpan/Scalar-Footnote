package TestNote2;

sub new { bless {}, $_[0] }

my $counter = 0;
sub counter { $counter   }
sub reset   { $counter=0 }
sub DESTROY { $counter++ }

1;
