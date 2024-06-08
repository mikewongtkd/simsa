package Shinsa::Group;
use base qw( Shinsa::DBO );
use List::MoreUtils qw( first_index );

# ============================================================
sub add {
# ============================================================
	my $self  = shift;
	my $user  = shift;
	my $class = $user->class();
	
	push @{$self->{ $class }}, $user;
}

# ============================================================
sub remove {
# ============================================================
	my $self  = shift;
	my $user  = shift;
	my $class = $user->class();
	my $uuid  = $user->uuid();

	my $i = first_index { $_->uuid() eq $uuid } @{$self->{ $class }};

	return 0 if( $i < 0 );

	return splice( @{ $self->{ $class }}, $i, 1 );
}

1;
