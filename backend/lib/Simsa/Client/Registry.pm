package Simsa::Client::Registry;
use lib qw( /usr/local/freescore/lib );
use List::Util qw( first );
use Simsa::Client;
use Simsa::DBO;

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
	$self->{ client } = {};
}

# ============================================================
sub add {
# ============================================================
# A User in an Exam may connect with multiple devices (clients)
# ------------------------------------------------------------
	my $self       = shift;
	my $websocket  = shift;
	my $client     = new Simsa::Client( $websocket );
	my $user       = $client->user->uuid();
	my $exam       = $client->exam->uuid();

	if( exists $self->{ client }{ $exam }{ $user }) {
		push @{$self->{ client }{ $exam }{ $user }}, $client;
	} else {
		$self->{ client }{ $exam }{ $user } = [ $client ];
	}

	return $client;
}

# ============================================================
sub audience {
# ============================================================
	my $self       = shift;
	my $client     = shift;
	my $exam       = $client->exam->uuid();
	my $audience   = { $client->uuid() => $client}; # Always include the client that sent the request
	my @groups     = $client->groups( where => { exam => $exam });
	my $group      = first { $_->panel() } @groups;
	my $panel      = $group->panel();
	my @others     = ();

	if( $panel() ) {
		push @others, map { $_->user->uuid() } $panel->computer_operators();
		push @others, map { $_->user->uuid() } $panel->examiners();
		push @others, map { $_->user->uuid() } $group->all_examinees();
	}

	foreach my $user (@users) {
		next unless exists $self->{ client }{ $exam }{ $user };
		foreach my $client (@{$self->{ client }{ $exam }{ $user }}) {
			my $uuid = $client->uuid();
			$audience->{ $uuid } = $client; # Add each individual device
		}
	}

	return values %$audience;
}

# ============================================================
sub remove {
# ============================================================
	my $self   = shift;
	my $client = shift;
	my $user   = $client->user->uuid();
	my $exam   = $client->exam->uuid();
	my $uuid   = $client->uuid();

	# Filter out all clients with the same Client UUID
	$self->{ $exam }{ $user } = [ grep { $_->uuid() ne $uuid } @{$self->{ $exam }{ $user }} ];

	# Prune unused branches
	delete $self->{ $exam }{ $user } unless @{$self->{ $exam }{ $user }};
	delete $self->{ $exam } unless keys %{$self->{ $exam }};
}

1;
