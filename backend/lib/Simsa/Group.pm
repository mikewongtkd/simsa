package Simsa::Group;
use base qw( Simsa::DBO );
use List::MoreUtils qw( first_index );

# ============================================================
sub add_examinee {
# ============================================================
	my $self     = shift;
	my $examinee = shift;

	$examinee = Simsa::DBO::_get( $examinee );
	
	push @{$self->{ data }{ examinee }}, $examinee;
	$self->write();
}

# ============================================================
sub add_group {
# ============================================================
	my $self  = shift;
	my $group = shift;

	push @{$self->{ data }{ group }}, $group;
	$self->write();
}

# ============================================================
sub all_examinees {
# ============================================================
	my $self      = shift;
	my @examinees = @{$self->{ data }{ examinee }};

	return @examinees unless exists $self->{ data }{ group };

	foreach my $group (@{$self->{ data }{ group }}) {
		$group = Simsa::DBO::_get( $group );

		# Recursively drill down
		push @examinees, $group->all_examinees();
	}
	return @examinees;
}

# ============================================================
sub remove_examinee {
# ============================================================
	my $self     = shift;
	my $examinee = shift;

	$examinee = Simsa::DBO::_get( $examinee );
	my $uuid  = $examinee->uuid();

	my $i = first_index { $_->uuid() eq $uuid } @{$self->{ data }{ examinee }};

	return 0 if( $i < 0 );

	$self->write();
	return splice( @{ $self->{ data }{ examinee }}, $i, 1 );
}

# ============================================================
sub remove_group {
# ============================================================
	my $self  = shift;
	my $group = shift;

	$group   = Simsa::DBO::_get( $group );
	my $uuid = $group->uuid();

	my $i = first_index { $_->uuid() eq $uuid } @{$self->{ data }{ group }};

	return 0 if( $i < 0 );

	$self->write();
	return splice( @{ $self->{ data }{ group }}, $i, 1 );
}


1;
