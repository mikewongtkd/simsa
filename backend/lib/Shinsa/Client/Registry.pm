package Shinsa::Client::Registry;
use lib qw( /usr/local/freescore/lib );
use Shinsa::Client::Group;
use Shinsa::Client;

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
	my $client     = new Shinsa::Client( $websocket );
	my $uuid       = $client->uuid();

	$self->{ exam } = exists $self->{ exam } ? $self->{ exam } : $client->exam();

	$self->{ client }{ $uuid } = $client;

	return $client;
}

# ============================================================
sub client {
# ============================================================
	my $self      = shift;
	my $id        = shift;
	my $client    = exists $self->{ client }{ $id } ? $self->{ client }{ $id } : undef;
	return $client;
}

# ============================================================
sub clients {
# ============================================================
	my $self    = shift;
	my $filter  = shift;
	my @clients = sort { $a->description() cmp $b->description() } values %{ $self->{ client }};

	if( $filter ) {
		@clients = grep { $_->role() =~ /^$filter/ } @clients;
	}

	return @clients;
}

# ============================================================
sub remove {
# ============================================================
	my $self       = shift;
	my $client     = shift;
	my $id         = undef;
	my $group      = undef;

	if( ref $client ) { $id = $client->id(); } 
	else {
		$id     = $client;
		$client = $self->{ client }{ $id };
	}
	my $user = $client->description();
	print STDERR "$user connection closed.\n";

	delete $self->{ client }{ $id } if exists $self->{ client }{ $id };
}

1;
