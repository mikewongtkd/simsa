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
	my $user       = $websocket->param( 'user' );
	my $sessid     = $websocket->cookie( 'shinsa-session' );

	$self->{ exam }       = Simsa::DBO::_get( $exam );
	$self->{ user }       = Simsa::DBO::_get( $user );
	$self->{ sessid }     = $sessid;
	$self->{ device }     = $connection;
	$self->{ websocket }  = $websocket;
	$self->{ status }     = 'strong'; 
}

# ============================================================
sub description {
# ============================================================
	my $self  = shift;
	my $user  = $self->{ user };
	my $uuid  = $self->uuid();
	my @roles = $self->roles();

	return sprintf( "%s (%s)", join( ', ', @roles), $uuid );
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
sub pong {
# ============================================================
# Synonym to ping() (i.e. return the Ping object, which also
# handles pong())
# ------------------------------------------------------------
	my $self = shift;
	return $self->ping();
}

# ============================================================
sub roles {
# ============================================================
	my $self = shift;
	my $user = $self->{ user };
	my $exam = $self->{ exam };

	return $user->roles( $exam );
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
	my @roles  = $self->roles();
	my $health = $ping ? $ping->health() : 'n/a';

	return { uuid => $uuid, roles => [ @roles ], health => $health };
}

sub device     { my $self = shift; return $self->{ device };       }
sub exam       { my $self = shift; return $self->{ exam };         }
sub sessid     { my $self = shift; return $self->{ sessid };       }
sub timedelta  { my $self = shift; return $self->{ timedelta };    }
sub user       { my $self = shift; return $self->{ user });        }
sub uuid       { my $self = shift; return $self->{ user }->uuid(); }

1;
