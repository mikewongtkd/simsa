package Simsa;
use base Clone;
use Simsa::User;
use Simsa::Exam;
use Data::Structure::Util qw( unbless );
use JSON::XS;
use Mojolicious::Controller;
use Simsa::Client::Ping;

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
	my $self       = shift;
	my $websocket  = shift;
	my $connection = $websocket->tx();
	my $exam       = $websocket->param( 'exam' );
	my $uuid       = $websocket->param( 'uuid' );
	my $roles      = $websocket->param( 'roles' );
	my $sessid     = $websocket->cookie( 'shinsa-session' );

	$self->{ exam }       = Simsa::DBO::_get( $exam );
	$self->{ uuid }       = Simsa::DBO::_get( $uuid );
	$self->{ roles }      = $roles;
	$self->{ sessid }     = $sessid;
	$self->{ device }     = $connection;
	$self->{ websocket }  = $websocket;
	$self->{ status }     = 'strong'; 
}

# ============================================================
sub description {
# ============================================================
	my $self = shift;
	my $uuid = $self->uuid();
	my $role = $self->role();

	return sprintf( "%s (%s)", $roles, $uuid );
}

# ============================================================
sub json {
# ============================================================
	my $self  = shift;
	my $clone = unbless( $self->clone());
	my $json  = new JSON::XS();

	# Remove nested objects
	delete $clone->{ $_ } foreach qw( device ping websocket );

	return $json->canonical->encode( $clone );
}

# ============================================================
sub ping {
# ============================================================
	my $self = shift;

	return $self->{ ping } if exists $self->{ ping };

	$self->{ ping } = new FreeScore::Client::Ping( $self );
	return $self->{ ping };
}

# ============================================================
sub send {
# ============================================================
	my $self = shift;
	$self->device->send( @_ );
}

# ============================================================
sub status {
# ============================================================
	my $self   = shift;
	my $ping   = exists $self->{ ping } ? $self->ping() : undef;
	my $uuid   = $self->uuid();
	my $role   = $self->role();
	my $health = $ping ? $ping->health() : 'n/a';

	return { uuid => $uuid, role => $role, health => $health };
}

sub device     { my $self = shift; return $self->{ device };     }
sub exam       { my $self = shift; return $self->{ exam };       }
sub roles      { my $self = shift; return $self->{ roles };      }
sub sessid     { my $self = shift; return $self->{ sessid };     }
sub timedelta  { my $self = shift; return $self->{ timedelta };  }
sub uuid       { my $self = shift; return $self->{ uuid };       }

1;
