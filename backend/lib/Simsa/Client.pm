package Simsa;
use base Clone;
use Simsa::User;
use Simsa::Exam;
use Data::Structure::Util qw( unbless );
use JSON::XS;
use Mojolicious::Controller;
use Simsa::Client::Ping;
use UUID;

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
	$self->{ uuid }       = lc UUID::uuid();
	$self->{ sessid }     = $sessid;
	$self->{ device }     = $connection;
	$self->{ websocket }  = $websocket;
	$self->{ status }     = 'strong'; 
}

# ============================================================
sub description {
# ============================================================
	my $self   = shift;
	my $uuid   = $self->uuid();
	my $sessid = $self->sessid();
	my $user   = $self->user->uuid();
	my $roles  = join( ', ', $self->user->roles());
	my $fname  = $user->fname();
	my $lname  = $user->lname();

	return sprintf( "%s %s %s %s (%s)", $sessid, $uuid, $fname, $lname, $roles );
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
sub sent_pong {
# ============================================================
	my $self    = shift;
	my $request = shift;

	return $self->ping->is_pong( $request );
}

# ============================================================
sub status {
# ============================================================
	my $self   = shift;
	my $ping   = exists $self->{ ping } ? $self->ping() : undef;
	my $uuid   = $self->uuid();
	my $user   = $self->user->uuid();
	my @roles  = $self->user->roles();
	my $health = $ping ? $ping->health() : 'n/a';

	return { uuid => $uuid, user => $user, roles => [ @roles ], health => $health };
}

# ============================================================
sub update_health {
# ============================================================
	my $self    = shift;
	my $request = shift;

	return $self->ping->handle( $request );
}

sub device     { my $self = shift; return $self->{ device };    }
sub exam       { my $self = shift; return $self->{ exam };      }
sub sessid     { my $self = shift; return $self->{ sessid };    }
sub timedelta  { my $self = shift; return $self->{ timedelta }; }
sub user       { my $self = shift; return $self->{ user });     }
sub uuid       { my $self = shift; return $self->{ uuid };      }

1;
