package Shinsa::Login;
use base qw( Shinsa::DBO );
use PHP::Functions::Password qw( password_hash password_verify );

# ============================================================
sub verify {
# ============================================================
	my $self = shift;
	my $hash = shift;

	return password_verify( $hash, $self->{ data }{ pwhash });
}

# ============================================================
sub write {
# ============================================================
	my $self     = shift;
	my $password = exists $self->{ data }{ password } ? $self->{ data }{ password } : undef;

	if( defined $password ) {
		delete $self->{ data }{ password };
		$self->{ data }{ pwhash } = password_hash( $password );
	}

	$self->SUPER::write();
}

1;
