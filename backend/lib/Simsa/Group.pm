package Simsa::Group;
use base qw( Simsa::DBO );
use List::MoreUtils qw( first_index );

# ============================================================
sub add_examinee {
# ============================================================
	my $self  = shift;
	my $user  = shift;
	
	push @{$self->{ examinee }}, $user;
}

# ============================================================
sub add_group {
# ============================================================
	my $self  = shift;
	my $group = shift;

	push @{$self->{ group }}, $group;
}

# ============================================================
sub remove_examinee {
# ============================================================
	my $self  = shift;
	my $user  = shift;
	my $uuid  = ref $user ? $user->uuid() : $user;

	my $i = first_index { $_->uuid() eq $uuid } @{$self->{ examinee }};

	return 0 if( $i < 0 );

	return splice( @{ $self->{ examinee }}, $i, 1 );
}

# ============================================================
sub remove_group {
# ============================================================
	my $self  = shift;
	my $group = shift;
	my $uuid  = ref $group ? $group->uuid() : $group;

	my $i = first_index { $_->uuid() eq $uuid } @{$self->{ group }};

	return 0 if( $i < 0 );

	return splice( @{ $self->{ group }}, $i, 1 );
}


1;
