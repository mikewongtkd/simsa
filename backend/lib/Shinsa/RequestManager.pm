package Shinsa::RequestManager;
use Shinsa::Promotion::Test;

# ============================================================
sub new {
# ============================================================
	my ($class) = map { ref || $_ } shift;
	my $self = bless {}, $class;
	$self->init( @_ );
	return $self;
}

# ============================================================
sub init {
# ============================================================
	my $self = shift;
	my $test = shift;
	$self->{ dispatch } = {};
	$self->{ test }     = new Shinsa::Promotion::Test( $test );
}

# ============================================================
sub handle {
# ============================================================
	my $self    = shift;
	my $id      = shift;
	my $request = shift;
	my $clients = shift;

	my $subject = $request->{ subject };
	my $action  = $request->{ action };
	my $test    = $self->{ test };
	my $user    = undef;
	my $role    = 'public';

	# ===== APPLY SECURITY POLICY
	if(    $test->official( $id )) { $user = $test->official( $id ); $role = $user->role(); }
	elsif( $test->examiner( $id )) { $user = $test->examiner( $id ); $role = 'examiner';    }
	elsif( $test->examinee( $id )) { $user = $test->examinee( $id ); $role = 'examinee';    }

	my $policy      = $test->policy();
	my $allowed     = $policy->allowed( $role, $subject, $action );

	die "Request forbidden\nID: $id Role: $role Subject: $subject Action: $action\n" unless exists $allowed;

	# ===== DISPATCH TO APPROPRIATE HANDLER, IF ONE IS AVAILABLE
	die "No handler for $subject $!" unless exists $self->{ dispatch }{ $subject };
	my $it = $self->{ dispatch }{ $subject };

	die "$subject cannot $action $!" unless $it->can( $action );

	my $do = $it->factory( $request );
	$do->$action( $id, $request, $clients );
}

# ============================================================
sub register {
# ============================================================
	my $self    = shift;
	my $handler = shift;

	my $object  = $handler->object();
	$self->{ dispatch }{ $object } = $handler;
}

1;
