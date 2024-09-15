package Simsa::Client::Ping;
use base qw( Clone );
use List::Util qw( sum );
use Data::Structure::Util qw( unbless );
use JSON::XS;
use Mojolicious::Controller;
use Mojo::IOLoop;
use Try::Tiny;

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
	my $self   = shift;
	my $client = shift;

	$self->{ pings }   = {};
	$self->{ client }  = $client;
	$self->{ latency } = 0;
	$self->{ time }    = { window => []};
	$self->{ speed }   = { normal => 60, fast => 30, faster => 10, fastest => 2 };
}

# ============================================================
sub changed {
# ============================================================
	my $self = shift;
	return 0 unless exists $self->{ health };
	my $health = $self->health();

	return $self->{ health } eq $health;
}

# ============================================================
sub fast {
# ============================================================
	my $self = shift;
	$self->go( $self->{ speed }{ fast });
}

# ============================================================
sub faster {
# ============================================================
	my $self = shift;
	$self->go( $self->{ speed }{ faster });
}

# ============================================================
sub fastest {
# ============================================================
	my $self = shift;
	$self->go( $self->{ speed }{ fastest });
}

# ============================================================
sub go {
# ============================================================
	my $self     = shift;
	my $interval = shift;
	return if $self->{ interval } == $interval;

	$self->stop();
	$self->start( $interval );
}

# ============================================================
sub health {
# ============================================================
	my $self    = shift;
	my $dropped = int( keys %{$self->{ pings }});
	my $latency = $self->{ latency };

	return 'strong' if( $dropped <= 1  || $latency <=  0.500 );
	return 'good'   if( $dropped <= 5  || $latency <=  1.000 );
	return 'weak'   if( $dropped <= 10 || $latency <=  2.000 );
	return 'bad'    if( $dropped <= 20 || $latency <=  5.000 );
	return 'dead'   if( $dropped >  20 || $latency <= 10.000 );
}

# ============================================================
sub latency {
# ============================================================
	my $self = shift;
	return $self->{ latency };
}

# ============================================================
sub normal {
# ============================================================
	my $self = shift;
	$self->go( $self->{ speed }{ normal });
}

# ============================================================
sub quit {
# ============================================================
	my $self   = shift;
	my $client = $self->{ client };
	my $id     = $self->{ id };

	return unless $id;

	Mojo::IOLoop->remove( $id );
	delete $self->{ id };
	delete $client->{ ping };
}

# ============================================================
sub sent_pong {
# ============================================================
	my $self    = shift;
	my $request = shift;
	return $request->{ subject } eq 'client' && $request->{ action } eq 'pong';
}

# ============================================================
sub start {
# ============================================================
	my $self     = shift;
	my $interval = shift || $self->{ speed }{ normal };
	my $client   = $self->{ client };

	$self->{ interval } = $interval;

	$self->{ id } = Mojo::IOLoop->recurring( $interval => sub ( $ioloop ) {
		my $now = time();
		$self->{ pings }{ $now } = 1;
		my $ping = { subject => 'server', action => 'ping', server => { timestamp => $now }};
		$client->send({ json => $ping });

		Mojo::IOLoop->timer(( $interval / 2 ) => sub ( $loop ) {
			$self->update_health();
			if( $self->changed()) {
				my $status = $client->status();
				$client->send({ json => $status });
			}
		});
	});
}

# ============================================================
sub stop {
# ============================================================
	my $self   = shift;
	my $id     = $self->{ id };

	return unless $id;

	Mojo::IOLoop->remove( $id );
	delete $self->{ id };
}

# ============================================================
sub update_health {
# ============================================================
	my $self   = shift;
	my $health = $self->health();

	if(    $health eq 'strong' ) { $self->normal();  }
	elsif( $health eq 'good'   ) { $self->fast();    }
	elsif( $health eq 'weak'   ) { $self->faster();  }
	elsif( $health eq 'bad '   ) { $self->fastest(); }
	elsif( $health eq 'dead'   ) { $self->stop();    }

	$self->{ health } = $health;
}

# ============================================================
sub update_latency {
# ============================================================
	my $self      = shift;
	my $request   = shift;
	my $client    = $self->{ client };
	my $server_ts = $request->{ server }{ timestamp };

	delete $self->{ pings }{ $server_ts } if( exists $self->{ pings }{ $server_ts });

	try {
		my $time1     = $server_ts;
		my $time2     = time();
		my $delta     = $time2 - $time1;
		my $window    = $self->{ time }{ window };

		$self->{ time }{ sum } += $delta;
		my $n = int( @$window );

		shift @$window if( $n >= 20 );
		$self->{ latency } = (sum @$window)/$n;

	} catch {

		print STDERR "One or more invalid dates ($server_ts, $client_ts) $_";
	};

	return $self->{ latency };
}

# ============================================================
sub _total_seconds {
# ============================================================
	my $delta = shift;
	my $weight = { h => 3600, m => 60, s => 1 };
	return sum map { int( $delta->printf( "\%$_\v" )) * $weight->{ $_ } } qw( h m s );
}

1;
