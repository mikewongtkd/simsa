package Shinsa::DataModel::Faker;

use lib qw( /usr/local/shinsa/lib );
use Math::Random qw( random_beta );
use Date::Manip;
use Data::Faker;
use Data::Faker::USNames;
use JSON::XS;
use POSIX qw( ceil floor round );

our $settings = {
	age => {
		min => 8,
		max => 92,
	}
};

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
	$self->{ faker } = new Data::Faker();

}

# ============================================================
sub user {
# ============================================================
	my $self   = shift;
	my $codes  = {"ad"=>"AND","ae"=>"ARE","af"=>"AFG","ag"=>"ATG","ai"=>"AIA","al"=>"ALB","am"=>"ARM","an"=>"ANT","ao"=>"AGO","aq"=>"ATA","ar"=>"ARG","as"=>"ASM","at"=>"AUT","au"=>"AUS","aw"=>"ABW","az"=>"AZE","ba"=>"BIH","bb"=>"BRB","bd"=>"BGD","be"=>"BEL","bf"=>"BFA","bg"=>"BGR","bh"=>"BHR","bi"=>"BDI","bj"=>"BEN","bm"=>"BMU","bn"=>"BRN","bo"=>"BOL","br"=>"BRA","bs"=>"BHS","bt"=>"BTN","bv"=>"BVT","bw"=>"BWA","by"=>"BLR","bz"=>"BLZ","ca"=>"CAN","cc"=>"CCK","cd"=>"COD","cf"=>"CAF","cg"=>"COG","ch"=>"CHE","ci"=>"CIV","ck"=>"COK","cl"=>"CHL","cm"=>"CMR","cn"=>"CHN","co"=>"COL","cr"=>"CRI","cu"=>"CUB","cv"=>"CPV","cx"=>"CXR","cy"=>"CYP","cz"=>"CZE","de"=>"DEU","dj"=>"DJI","dk"=>"DNK","dm"=>"DMA","do"=>"DOM","dz"=>"DZA","ec"=>"ECU","ee"=>"EST","eg"=>"EGY","eh"=>"ESH","er"=>"ERI","es"=>"ESP","et"=>"ETH","fi"=>"FIN","fj"=>"FJI","fk"=>"FLK","fm"=>"FSM","fo"=>"FRO","fr"=>"FRA","ga"=>"GAB","gb"=>"GBR","gd"=>"GRD","ge"=>"GEO","gf"=>"GUF","gg"=>"GGY","gh"=>"GHA","gi"=>"GIB","gl"=>"GRL","gm"=>"GMB","gn"=>"GIN","gp"=>"GLP","gq"=>"GNQ","gr"=>"GRC","gs"=>"SGS","gt"=>"GTM","gu"=>"GUM","gw"=>"GNB","gy"=>"GUY","hk"=>"HKG","hm"=>"HMD","hn"=>"HND","hr"=>"HRV","ht"=>"HTI","hu"=>"HUN","id"=>"IDN","ie"=>"IRL","il"=>"ISR","im"=>"IMN","in"=>"IND","io"=>"IOT","iq"=>"IRQ","ir"=>"IRN","is"=>"ISL","it"=>"ITA","je"=>"JEY","jm"=>"JAM","jo"=>"JOR","jp"=>"JPN","ke"=>"KEN","kg"=>"KGZ","kh"=>"KHM","ki"=>"KIR","km"=>"COM","kn"=>"KNA","kp"=>"PRK","kr"=>"KOR","kw"=>"KWT","ky"=>"CYM","kz"=>"KAZ","la"=>"LAO","lb"=>"LBN","lc"=>"LCA","li"=>"LIE","lk"=>"LKA","lr"=>"LBR","ls"=>"LSO","lt"=>"LTU","lu"=>"LUX","lv"=>"LVA","ly"=>"LBY","ma"=>"MAR","mc"=>"MCO","md"=>"MDA","me"=>"MNE","mg"=>"MDG","mh"=>"MHL","mk"=>"MKD","ml"=>"MLI","mm"=>"MMR","mn"=>"MNG","mo"=>"MAC","mp"=>"MNP","mq"=>"MTQ","mr"=>"MRT","ms"=>"MSR","mt"=>"MLT","mu"=>"MUS","mv"=>"MDV","mw"=>"MWI","mx"=>"MEX","my"=>"MYS","mz"=>"MOZ","na"=>"NAM","nc"=>"NCL","ne"=>"NER","nf"=>"NFK","ng"=>"NGA","ni"=>"NIC","nl"=>"NLD","no"=>"NOR","np"=>"NPL","nr"=>"NRU","nu"=>"NIU","nz"=>"NZL","om"=>"OMN","pa"=>"PAN","pe"=>"PER","pf"=>"PYF","pg"=>"PNG","ph"=>"PHL","pk"=>"PAK","pl"=>"POL","pm"=>"SPM","pn"=>"PCN","pr"=>"PRI","ps"=>"PSE","pt"=>"PRT","pw"=>"PLW","py"=>"PRY","qa"=>"QAT","re"=>"REU","ro"=>"ROU","rs"=>"SRB","ru"=>"RUS","rw"=>"RWA","sa"=>"SAU","sb"=>"SLB","sc"=>"SYC","sd"=>"SDN","se"=>"SWE","sg"=>"SGP","sh"=>"SHN","si"=>"SVN","sj"=>"SJM","sk"=>"SVK","sl"=>"SLE","sm"=>"SMR","sn"=>"SEN","so"=>"SOM","sr"=>"SUR","ss"=>"SSD","st"=>"STP","sv"=>"SLV","sy"=>"SYR","sz"=>"SWZ","tc"=>"TCA","td"=>"TCD","tf"=>"ATF","tg"=>"TGO","th"=>"THA","tj"=>"TJK","tk"=>"TKL","tl"=>"TLS","tm"=>"TKM","tn"=>"TUN","to"=>"TON","tr"=>"TUR","tt"=>"TTO","tv"=>"TUV","tw"=>"TWN","tz"=>"TZA","ua"=>"UKR","ug"=>"UGA","um"=>"UMI","us"=>"USA","uy"=>"URY","uz"=>"UZB","va"=>"VAT","vc"=>"VCT","ve"=>"VEN","vg"=>"VGB","vi"=>"VIR","vn"=>"VNM","vu"=>"VUT","wf"=>"WLF","ws"=>"WSM","ye"=>"YEM","yt"=>"MYT","za"=>"ZAF","zm"=>"ZMB","zw"=>"ZWE"};
	my $fake   = $self->{ faker };
	my $gender = rand() > 0.5 ? 'm' : 'f';
	my $dob    = _birthday();
	my $fname  = $fake->us_first_name->( $gender, $dob->printf( '%Y' ));
	my $lname  = $fake->last_name();
	my $id     = int( sprintf( '0%d%6d', int( rand() * 9 ) + 1, int( rand() * 999999 )));
	my $rank   = _rank_history( $dob );
	my $email  = lc( sprintf( '%s%s@%s', substr( $fname, 0, 1 ), $lname, $fake->domain_name())); $email =~ s/\s+//g;
	my $code2  = lc((split /\./, $email)[ -1 ]);
	my $noc    = exists $codes->{ $code2 } ? $codes->{ $code2 } : 'usa';
	my $json   = new JSON::XS();

	return {
		fname  => $fname,
		lname  => $lname,
		email  => $email,
		dob    => $dob->printf( "%OZ" ),
		gender => $gender,
		rank   => $json->canonical->encode( $rank ),
		noc    => $noc
	};
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
sub _birthday {
# ============================================================
	my $now   = new Date::Manip::Date( 'now' );
	my $age   = (_beta( 1, 4.7 ) * ($settings->{ age }{ max } = $settings->{ age }{ min }) ) + $settings->{ age }{ min };
	my $delta = _delta_years( $age );
	my $bday  = $now->calc( $delta, 1 );

	$bday->convert( 'utc' );
	return $bday;
}

# ============================================================
sub _delta_days {
# ============================================================
	my $days = shift;
	my $text = sprintf( "%.3f days", $days );
	return new Date::Manip::Delta( $text );
}

# ============================================================
sub _delta_years {
# ============================================================
	my $years = shift;
	my $text  = sprintf( "%.3f years", $years );
	return new Date::Manip::Delta( $text );
}

# ============================================================
sub _rank_history {
# ============================================================
	my $dob  = shift;
	my $now  = new Date::Manip::Date( 'now' );
	my $year = int( $now->printf( '%Y' ));
	my $yob  = int( $dob->printf( '%Y' ));
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
		my $yop       = int( $promotion->printf( 'Y' ));
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

	return $history;
}

# ============================================================
sub _date {
# ============================================================
	my $date = new Date::Manip::Date( 'now' );
	$date->convert( 'utc' );
	return $date;
}

1;
