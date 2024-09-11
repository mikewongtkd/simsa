package Simsa::Client::Registry;
use lib qw( /usr/local/freescore/lib );
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
sub clients {
# ============================================================
	my $self       = shift;
	my $client     = shift;
	my $audience   = shift;
	my $exam       = $client->exam->uuid();
	my $clients    = { $client->uuid() => $client }; # Always include the client that sent the request

	foreach my $document (@$audience) {
		my $class = $document->class();

		my @users = ();
		if( $class =~ /role/i ) {
			my $role = $document;
			push @users, $role->user->uuid();

		} elsif( $class =~ /group/i ) {
			my $group = $document;
			push @users, map { $_->user->uuid() } $group->all_examinees();

		} elsif( $class =~ /panel/i ) {
			my $panel = $document;
			push @users, map { $_->user->uuid() } $panel->computer_operators();
			push @users, map { $_->user->uuid() } $panel->examiners();
			push @users, map { $_->user->uuid() } $panel->group->all_examinees();
		}

		foreach my $user (@users) {
			next unless exists $self->{ client }{ $exam }{ $user };
			foreach my $client (@{$self->{ client }{ $exam }{ $user }}) {
				my $uuid = $client->uuid();
				$clients->{ $uuid } = $client;
			}
		}
	}

	return values %$clients;
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
