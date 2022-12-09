package Shinsa::Security::Policy;

use Try::Tiny;
use Shinsa::User;

# ============================================================
sub new {
# ============================================================
	my ($class) = map { ref || $_ } shift;
	my $self = bless {}, $class;
	$self->init();
	return $self;
}

# ============================================================
sub init {
# ============================================================
	my $self = shift;
}

# ============================================================
sub user {
# ============================================================
	my $self  = shift;
	my $uuid  = shift;

	try {
		my $user  = Shinsa::User::fetch( $uuid );
		my $login = $user->login();
		my $role  = $login->role();
		
	} catch {
		return undef;
	}
}

1;
