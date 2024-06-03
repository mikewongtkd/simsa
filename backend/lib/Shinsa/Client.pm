package Shinsa;
use base Clone;
use Data::Structure::Util qw( unbless );
use Digest::SHA1 qw( sha1_hex );
use JSON::XS;
use Mojolicious::Controller;
use Shinsa::Client::Ping;

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
	my $uuid       = $websocket->param( 'uuid' );
	my $sessid     = $websocket->cookie( 'shinsa-session' );
	my $id         = sha1_hex( $connection );

	$self->{ uuid }       = $uuid;
	$self->{ sessid }     = $sessid;
	$self->{ device }     = $connection;
	$self->{ websocket }  = $websocket;
	$self->{ status }     = 'strong'; 
}

# ============================================================
sub description {
# ============================================================
	my $self   = shift;
	my $cid    = $self->cid();
	my $role   = $self->role();
	$role = join( ' ', map { ucfirst } split( /(?:\s)/, $role ));
	my $jid = $self->jid();
	$role = $jid == 0 ? 'Referee' : "Judge $jid" if defined $jid;

	return sprintf( "%s (%s)", $role, $cid );
}

# ============================================================
sub cid {
# ============================================================
	my $self = shift;
	return sprintf( "%s-%s", substr( $self->sessid(), 0, 4 ), substr( $self->uuid(), 0, 4 ));
}

# ============================================================
sub group {
# ============================================================
	my $self  = shift;
	my $group = shift;

	if( $group ) {
		$self->{ group } = $group;
		$self->{ gid }   = $group->id();
	}
	return $self->{ group };
}

# ============================================================
sub jid {
# ============================================================
	my $self = shift;
	my $role = $self->role();
	return undef unless $role =~ /^examiner/i;
	return $jid;
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
sub Role {
# ============================================================
	my $self = shift;
	my $role = $self->role();
	$role = join( ' ', map { ucfirst } split /\s/, $role );
	return $role;
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
	my $cid    = $self->cid();
	my $ping   = exists $self->{ ping } ? $self->ping() : undef;
	my $role   = $self->Role();
	my $health = $ping ? $ping->health() : 'n/a';

	return { cid => $cid, role => $role, health => $health };
}

sub device     { my $self = shift; return $self->{ device };     }
sub exam       { my $self = shift; return $self->{ exam };       }
sub gid        { my $self = shift; return $self->{ gid };        }
sub uuid       { my $self = shift; return $self->{ uuid };         }
sub panel      { my $self = shift; return $self->{ panel };      }
sub role       { my $self = shift; return $self->{ role };       }
sub sessid     { my $self = shift; return $self->{ sessid };     }
sub timedelta  { my $self = shift; return $self->{ timedelta };  }

1;
