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
	my $result   = shift;
	my $client   = shift;
	my $registry = shift;
	my $audience = shift;

	my @clients  = $registry->clients( $client, $audience );
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

	my @params = map { $request->{ $_ }} @keys;
	my ($result, $audience) = $self->$callback( @params );

	$self->broadcast( $result, $client, $registry, $audience );
}

# ============================================================
sub handle_examiner_score_examinee {
# ============================================================
	my $self     = shift;
	my $examiner = shift;
	my $score    = shift;
	my $examinee = shift;

	$score = new Simsa::Score( %$score, examiner => $examiner, examinee => $examinee );

	return ($score, [ $examiner->uuid(), $examinee->uuid(), $examiner->panel->uuid() ]);
}

1;
