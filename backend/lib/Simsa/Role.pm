package Simsa::Role;
use base qw( Simsa::DBO );

# ============================================================
sub get {
# ============================================================
	my $self  = shift;
	my $query = shift;

	my $results = $self->SUPER::get( $query );

	return $results if( $results );

	my $user = $self->SUPER::get( 'user' );

	return $user->get( $query );
}

1;
