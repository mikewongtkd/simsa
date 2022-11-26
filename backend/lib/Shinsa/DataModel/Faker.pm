package Shinsa::DataModel::Faker;

use lib qw( /usr/local/shinsa/lib );
use Math::Random qw( random_beta );
use Date::Manip;
use POSIX qw( ceil floor round );

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

}

# ============================================================
sub birthday {
# ============================================================
	my $self  = shift;
	my $now   = new Date::Manip::Date( 'now' );
	my $age   = (_beta( 1, 4.7 ) * 84) + 8;
	my $text  = sprintf( "%.3f years", $age );
	my $delta = new Date::Manip::Delta( $text );
	my $bday  = $now->calc( $delta, 1 );

	$bday->convert( 'utc' );
	return $bday;
}

# ============================================================
sub _beta {
# ============================================================
	my $alpha   = shift;
	my $beta    = shift;
	my ($value) = random_beta( 1, $alpha, $beta );

	return $value;
}

# ============================================================
sub _delta_days {
# ============================================================
	my $days = shift;
	my $text = sprintf( "%.3f days", $days );
	return new Date::Manip::Delta( $text );
}

# ============================================================
sub _rank_history {
# ============================================================
	my $dob  = shift;
	my $now  = new Date::Manip::Date( 'now' );
	my $year = int( $now->printf( 'Y' ));
	my $yob  = int( $dob->printf( 'Y' ));
	my $age  = $year - $yob;
	my $n    = ceil( log( $age - 6 ) / log( 2 ));
	my $rank = round( _beta( 4, 2 ) * $n );

	$rank = $rank == 0 ? 1 : $rank;

	my $history = [];
	my $date    = new Date::Manip::Date( 'now' );

	for( my $i = $rank; $i > 0; $i-- ) {
		my $days      = _beta( 2, 8 ) * $i * $n * 365;
		my $delta     = _delta_days( $days );
		my $promotion = $date->calc( $delta, 1 ); $promotion->convert( 'utc' );
		my $yop       = int( $promotion->printf( 'Y' ))
		my $age       = $yop - $yob;
		my $danpoom   = $age <= 14 ? 'poom' : 'dan';
		if( $danpoom eq 'poom' && $rank > 4 ) { $danpoom = 'dan'; }
		push @$history, { rank => $i, danpoom => $danpoom, date => $promotion->printf( "%OZ" )};

		if( $days < ( $i * 365 )) {
			my $delta = _delta_days( $i * _beta( 2, 8 ) * 365 );
			$date = $date->calc( $delta, 1 ); $date->convert( 'utc' );

		} else {
			$date = $promotion;
		}
	}
}

# ============================================================
sub _date {
# ============================================================
	my $date = new Date::Manip::Date( 'now' );
	$date->convert( 'utc' );
	return $date;
}

1;
