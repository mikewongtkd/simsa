package Simsa::Role;
use base qw( Simsa::DBO );
use vars '$AUTOLOAD';

our $order = {
	Root             => 0,
	Technician       => 1,
	ComputerOperator => 2,
	Examiner         => 3,
	Examinee         => 4
};

# ============================================================
sub AUTOLOAD {
# ============================================================
	my $self   = shift;
	my $n      = int( @_ );

	if( $n == 1 ) {
		my $value = shift;
		my $field = _field( $AUTOLOAD );
		Simsa::DBO::set( $self, $field, $value );

	} elsif( $n > 1 ) {
		warn "Extra parameters to $AUTOLOAD were ignored $!";

	} else {
		my $results = Simsa::DBO::get( $self, $AUTOLOAD );
		return $results if $results;

		return unless exists( $self->{ data }{ user });

		my $user  = Simsa::DBO::_get( $self->{ data }{ user });
		my $field = Simsa::DBO::_field( $AUTOLOAD );
		return Simsa::DBO::get( $user, $AUTOLOAD ) if( exists( $user->{ data }{ $field }));
	}
}

# ============================================================
sub role {
# ============================================================
	my $self = shift;
	my $user = Simsa::DBO::_get( $self->{ data }{ user });
	my $exam = Simsa::DBO::_get( $self->{ data }{ exam });

	return $user->role( $exam );
}

# ============================================================
sub roles {
# ============================================================
	my $self = shift;
	my $user = Simsa::DBO::_get( $self->{ data }{ user });
	my $exam = Simsa::DBO::_get( $self->{ data }{ exam });

	return $user->roles( $exam );
}

1;
