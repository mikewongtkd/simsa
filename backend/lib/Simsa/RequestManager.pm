package Simsa::RequestManager;
use Simsa;

our $audience = {
	user => {
		connect => [ qw( admin staff panel )],
		disconnect => [ qw( admin staff panel )]
	},
	examiner => {
		score => {
			examinee => [ qw( admin staff panel )]
		}
	}
}

# ============================================================
sub new {
# ============================================================
	my ($class) = map { ref || $_ } shift;
	my $table   = Simsa::DBO::_class( $class );
	my $self    = bless {}, $class;
	return $self;
}

# ============================================================
sub broadcast {
# ============================================================
	my $self     = shift;
	my $request  = shift;
	my $result   = shift;
	my $client   = shift;
	my $registry = shift;
	my $audience = shift;
	my @clients  = $registry->clients( $client, $audience );

	foreach my $client (@clients) {
		$client->send({ json => { result => $result->document(), request => $request }});
	}
}

# ============================================================
sub get {
# ============================================================
	my $self = shift;
	my $uuid = shift;
	my $item = Simsa::DBO::_get( $uuid );
	return $item;
}

# ============================================================
sub handle {
# ============================================================
	my $self     = shift;
	my $client   = shift;
	my $request  = shift;
	my $registry = shift;
	my @keys     = ();

	foreach my $key (qw( subject action object )) {
		next unless exists $request->{ $key } && $request->{ $key };
		push @keys, lc $key;
	}

	my $callback = "handle_" . join( "_", map { s/\W/_/g; $_ } @keys );
	die "No request handler for '" . join( ' ', map { ucfirst } @keys ) . "' $!" unless $self->can( $callback );

	my @params = map { exists $request->{ $_ } ? $request->{ $_ } : () } @keys;
	my ($result, $audience) = $self->$callback( $request, @params );

	$self->broadcast( $request, $result, $client, $registry, $audience );
}

# ============================================================
sub handle_group_add_examinee {
# ============================================================
	my $self     = shift;
	my $request  = shift;
	my $group    = shift;
	my $examinee = shift;

	$group    = Simsa::DBO::_get( $group );
	$examinee = Simsa::DBO::_get( $examinee );

	$group->add_examinee( $examinee );

	return ($group, [ $group ]);
}

# ============================================================
sub handle_group_add_group {
# ============================================================
	my $self     = shift;
	my $request  = shift;
	my $group    = shift;

	my $source  = Simsa::DBO::_get( $group->{ source });
	my $target  = Simsa::DBO::_get( $group->{ target });

	$source->add_group( $target );

	return ($source, [ $source ]);
}

# ============================================================
sub handle_group_remove_examinee {
# ============================================================
	my $self     = shift;
	my $request  = shift;
	my $group    = shift;
	my $examinee = shift;

	$group    = Simsa::DBO::_get( $group );
	$examinee = Simsa::DBO::_get( $examinee );

	$group->remove_examinee( $examinee );

	return ($group, [ $examinee, $group ]);
}

# ============================================================
sub handle_group_remove_group {
# ============================================================
	my $self     = shift;
	my $request  = shift;
	my $group    = shift;

	my $source  = Simsa::DBO::_get( $group->{ source });
	my $target  = Simsa::DBO::_get( $group->{ target });

	$source->remove_group( $target );

	return ($source, [ $source, $target ]);
}

# ============================================================
sub handle_score_examinee {
# ============================================================
# Subject: None
# Action:  Score
# Object:  Examinee
# Required Field: Examiner (UUID)
# ------------------------------------------------------------
	my $self     = shift;
	my $request  = shift;
	my $score    = shift;
	my $examinee = shift;
	my $examiner = $request->{ examiner };

	$score = new Simsa::Score( %$score, examiner => $examiner, examinee => $examinee );

	return ($score, [ $examiner, $examinee, $examiner->panel() ]);
}

# ============================================================
sub broadcast_user_connect {
# ============================================================
	my $self       = shift;
	my $connection = shift;
	my $registry   = shift;
	my $client     = $registry->add( $connection );
	my $user       = $client->user();
	my $exam       = $client->exam();

	my $request = { subject => 'user', action => 'connect', user => { sessid => $client->sessid(), uuid => $user->uuid(), roles => $user->roles( $exam ) }};

	my $audience = []
}

# ============================================================
sub broadcast_user_disconnect {
# ============================================================
	my $self     = shift;
	my $client   = shift;
	my $registry = shift;

	my $group    = $user->group();
}

1;
