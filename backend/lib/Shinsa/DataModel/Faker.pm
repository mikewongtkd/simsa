package Shinsa::DataModel::Faker;

use lib qw( /usr/local/shinsa/lib );
use Data::Faker;
use Data::Faker::USNames;
use Date::Manip;
use Digest::SHA1 qw( sha1_hex );
use JSON::XS;
use List::MoreUtils qw( part );
use Math::Random qw( random_beta );
use POSIX qw( ceil floor round );
use UUID;

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
sub cohort {
# ============================================================
	my $self        = shift;
	my $exam        = shift;
	my $rank        = shift;
	my $panel       = shift;
	my $parent      = shift;
	my $fake        = $self->{ faker };
	my $description = sprintf( "%s Dan Promotion", _ordinal( $rank ));
	my $uuid        = UUID::uuid();

	return {
		uuid        => $uuid,
		exam        => $exam->{ uuid },
		panel       => $panel->{ uuid },
		location    => "Main training area",
		name        => $description,
		description => $description,
		parent      => $parent->{ uuid }
	};
}

# ============================================================
sub exam {
# ============================================================
	my $self    = shift;
	my $poster  = shift;
	my $fake    = $self->{ faker };
	my $uuid    = UUID::uuid();
	my $state   = $fake->us_state());
	my $name    = "$state State Kukkiwon Dan Examination";
	my $host    = "$state State Taekwondo Association";
	my $address = { line1 => $fake->street_address(), state => $state, postcode => $fake->us_zip_code(), city => $fake->city()};
	my $now     = new Date::Manip::Date( 'now' ); $now->convert( 'utc' );
	my $start   = $now;
	my $desc    = $name;
	my $url     = sprintf( "https://%s", $fake->domain_name());
	my $json    = new JSON::XS();

	return {
		uuid        => $uuid,
		name        => $name,
		poster      => $poster->{ uuid },
		host        => $host,
		address     => $json->canonical->encode( $address ),
		start       => $start,
		description => $desc,
		url         => $url
	};
}

# ============================================================
sub examinee {
# ============================================================
	my $self    = shift;
	my $user    = shift;
	my $exam    = shift;
	my $cohort  = shift;
	my $fake    = $self->{ faker };
	my $uuid    = UUID::uuid();
	my $id      = sprintf( '0%d%6d', int( $rank ), int( rand() * 999999 ));

	return {
		uuid   => $uuid,
		user   => $user->{ uuid },
		exam   => $exam->{ uuid },
		id     => $id,
		cohort => $cohort->{ uuid },
	};
}

# ============================================================
sub examiner {
# ============================================================
	my $self    = shift;
	my $user    = shift;
	my $exam    = shift;
	my $fake    = $self->{ faker };
	my $uuid    = UUID::uuid();

	return {
		uuid        => $uuid,
		user        => $user->{ uuid },
		exam        => $exam->{ uuid },
	};
}

# ============================================================
sub group_examinees_into_cohorts {
# ============================================================
	my $self        = shift;
	my $users       = shift;
	my $examination = shift;
	my $count       = shift;
	my $examinees   = [];
	my $cohorts     = [];
	my $ranks       = {};
	my $groupby     = {};

	foreach my $i ($count->{ staff } .. $count->{ users }) {
		my $user = $users->[ $i ];
		my ($highest) = sort { $b->{ rank } <=> $a->{ rank } } @{$user->{ rank }};
		push @{$ranks->{ $highest->{ rank }}}, $user;
	}

	foreach my $rank (sort keys %$ranks) {
		my $i      = $rank % $count->{ panels };
		my $users  = $ranks->{ $rank };
		my $cohort = undef;
		my $j      = 1;
		my $k      = -1;
		my $n      = $count->{ cohort }{ size };
		my $groups = [ part { int( ++$k / $n )} @$users ];

		foreach my $group (@$groups) {
			if( exists $groupby->{ $rank }) {
				my $parent = $groupby->{ $rank };
				$cohort = $self->cohort( $examination, $rank, $panels->[ $i ], $parent );
				$cohort->{ name } = "Group $j";
				push @{ $parent->{ _children }}, $cohort;
				$j++;

			} else {
				$groupby->{ $rank } = $self->cohort( $examination, $rank, $panels->[ $i ], { uuid => '' });
			}
			foreach my $user (@$group) {
				my $examinee = $self->examinee( $user, $examination, $cohort );
				push @$examinees, [ @{$examinee{ qw( uuid user exam id cohort )}];
			}
		}
	}
	foreach my $rank (sort { $a <=> $b } keys $groupby) {
		my $cohort = $groupby->{ rank };
		push @$cohorts, [ @{$cohort{ qw( uuid exam panel location name description parent ) }}];
		push @$cohorts, map { [ @{ $_{ qw( uuid exam panel location name description parent )}}]} @{ $cohort->{ _children }};
	}

	return ($examinees, $cohorts);
}

# ============================================================
sub group_examiners_into_panels {
# ============================================================
	my $self            = shift;
	my $users           = shift;
	my $examination     = shift;
	my $count           = shift;
	my $examiners       = [];
	my $panels          = [];
	my $panel_examiners = [];

	for my $i ( 1 .. $count->{ panels }) {
		my $panel = $self->panel( $examination );
		$panel->{ name } = "Panel $i";
		push @$panels, [ @{$panel{ qw( uuid exam name )}}];
	}
	for my $i ( 1 .. $count->{ examiners } ) {
		my $user     = $users->[ $i ];
		my $examiner = $self->examiner( $user, $examination );
		push @$examiners, [ @{$examiner{ qw( uuid user exam )}}];

		my $j        = ($i % $count->{ panels });
		my $panel    = $panels->[ $j ];
		my $panex    = $self->panel_examiner( $panel, $examiner );
		push @$panel_examiners, [ @{$panex{ qw( uuid panel examiner start stop )}}];
	}

	return ($examiners, $panels, $panel_examiners);
}

# ============================================================
sub login {
# ============================================================
	my $self   = shift;
	my $fake   = $self->{ faker };
	my $uuid   = UUID::uuid();
	my $gender = rand() > 0.5 ? 'm' : 'f';
	my $dob    = _birthday();
	my $fname  = $fake->us_first_name->( $gender, $dob->printf( '%Y' ));
	my $lname  = $fake->last_name();
	my $email  = lc( sprintf( '%s.%s@%s', $fname, $lname, $fake->domain_name())); $email =~ s/[^\w\.\_\-\@]//g;
	my $pwhash = substr( sha1_hex( $uuid ), 0, 40 );

	return {
		uuid    => $uuid,
		email   => $email,
		pwhash  => substr( sha1_hex( $uuid ), 0, 40 ),
		_gender => $gender,
		_fname  => $fname,
		_lname  => $lname,
		_dob    => $dob,
	};
}

# ============================================================
sub panel {
# ============================================================
	my $self   = shift;
	my $exam   = shift;
	my $fake   = $self->{ faker };
	my $uuid   = UUID::uuid();

	return {
		uuid => $uuid,
		exam => $exam->{ uuid },
		name => "Panel 1"
	};
}

# ============================================================
sub panel_examiner {
# ============================================================
	my $self     = shift;
	my $panel    = shift;
	my $examiner = shift;
	my $fake     = $self->{ faker };
	my $uuid     = UUID::uuid();

	return {
		uuid     => $uuid,
		panel    => $panel->{ uuid },
		examiner => $examiner->{ uuid },
		start    => '',
		stop     => ''
	};
}

# ============================================================
sub user {
# ============================================================
	my $self   = shift;
	my $login  = shift;
	my $codes  = {"ad"=>"AND","ae"=>"ARE","af"=>"AFG","ag"=>"ATG","ai"=>"AIA","al"=>"ALB","am"=>"ARM","an"=>"ANT","ao"=>"AGO","aq"=>"ATA","ar"=>"ARG","as"=>"ASM","at"=>"AUT","au"=>"AUS","aw"=>"ABW","az"=>"AZE","ba"=>"BIH","bb"=>"BRB","bd"=>"BGD","be"=>"BEL","bf"=>"BFA","bg"=>"BGR","bh"=>"BHR","bi"=>"BDI","bj"=>"BEN","bm"=>"BMU","bn"=>"BRN","bo"=>"BOL","br"=>"BRA","bs"=>"BHS","bt"=>"BTN","bv"=>"BVT","bw"=>"BWA","by"=>"BLR","bz"=>"BLZ","ca"=>"CAN","cc"=>"CCK","cd"=>"COD","cf"=>"CAF","cg"=>"COG","ch"=>"CHE","ci"=>"CIV","ck"=>"COK","cl"=>"CHL","cm"=>"CMR","cn"=>"CHN","co"=>"COL","cr"=>"CRI","cu"=>"CUB","cv"=>"CPV","cx"=>"CXR","cy"=>"CYP","cz"=>"CZE","de"=>"DEU","dj"=>"DJI","dk"=>"DNK","dm"=>"DMA","do"=>"DOM","dz"=>"DZA","ec"=>"ECU","ee"=>"EST","eg"=>"EGY","eh"=>"ESH","er"=>"ERI","es"=>"ESP","et"=>"ETH","fi"=>"FIN","fj"=>"FJI","fk"=>"FLK","fm"=>"FSM","fo"=>"FRO","fr"=>"FRA","ga"=>"GAB","gb"=>"GBR","gd"=>"GRD","ge"=>"GEO","gf"=>"GUF","gg"=>"GGY","gh"=>"GHA","gi"=>"GIB","gl"=>"GRL","gm"=>"GMB","gn"=>"GIN","gp"=>"GLP","gq"=>"GNQ","gr"=>"GRC","gs"=>"SGS","gt"=>"GTM","gu"=>"GUM","gw"=>"GNB","gy"=>"GUY","hk"=>"HKG","hm"=>"HMD","hn"=>"HND","hr"=>"HRV","ht"=>"HTI","hu"=>"HUN","id"=>"IDN","ie"=>"IRL","il"=>"ISR","im"=>"IMN","in"=>"IND","io"=>"IOT","iq"=>"IRQ","ir"=>"IRN","is"=>"ISL","it"=>"ITA","je"=>"JEY","jm"=>"JAM","jo"=>"JOR","jp"=>"JPN","ke"=>"KEN","kg"=>"KGZ","kh"=>"KHM","ki"=>"KIR","km"=>"COM","kn"=>"KNA","kp"=>"PRK","kr"=>"KOR","kw"=>"KWT","ky"=>"CYM","kz"=>"KAZ","la"=>"LAO","lb"=>"LBN","lc"=>"LCA","li"=>"LIE","lk"=>"LKA","lr"=>"LBR","ls"=>"LSO","lt"=>"LTU","lu"=>"LUX","lv"=>"LVA","ly"=>"LBY","ma"=>"MAR","mc"=>"MCO","md"=>"MDA","me"=>"MNE","mg"=>"MDG","mh"=>"MHL","mk"=>"MKD","ml"=>"MLI","mm"=>"MMR","mn"=>"MNG","mo"=>"MAC","mp"=>"MNP","mq"=>"MTQ","mr"=>"MRT","ms"=>"MSR","mt"=>"MLT","mu"=>"MUS","mv"=>"MDV","mw"=>"MWI","mx"=>"MEX","my"=>"MYS","mz"=>"MOZ","na"=>"NAM","nc"=>"NCL","ne"=>"NER","nf"=>"NFK","ng"=>"NGA","ni"=>"NIC","nl"=>"NLD","no"=>"NOR","np"=>"NPL","nr"=>"NRU","nu"=>"NIU","nz"=>"NZL","om"=>"OMN","pa"=>"PAN","pe"=>"PER","pf"=>"PYF","pg"=>"PNG","ph"=>"PHL","pk"=>"PAK","pl"=>"POL","pm"=>"SPM","pn"=>"PCN","pr"=>"PRI","ps"=>"PSE","pt"=>"PRT","pw"=>"PLW","py"=>"PRY","qa"=>"QAT","re"=>"REU","ro"=>"ROU","rs"=>"SRB","ru"=>"RUS","rw"=>"RWA","sa"=>"SAU","sb"=>"SLB","sc"=>"SYC","sd"=>"SDN","se"=>"SWE","sg"=>"SGP","sh"=>"SHN","si"=>"SVN","sj"=>"SJM","sk"=>"SVK","sl"=>"SLE","sm"=>"SMR","sn"=>"SEN","so"=>"SOM","sr"=>"SUR","ss"=>"SSD","st"=>"STP","sv"=>"SLV","sy"=>"SYR","sz"=>"SWZ","tc"=>"TCA","td"=>"TCD","tf"=>"ATF","tg"=>"TGO","th"=>"THA","tj"=>"TJK","tk"=>"TKL","tl"=>"TLS","tm"=>"TKM","tn"=>"TUN","to"=>"TON","tr"=>"TUR","tt"=>"TTO","tv"=>"TUV","tw"=>"TWN","tz"=>"TZA","ua"=>"UKR","ug"=>"UGA","um"=>"UMI","us"=>"USA","uy"=>"URY","uz"=>"UZB","va"=>"VAT","vc"=>"VCT","ve"=>"VEN","vg"=>"VGB","vi"=>"VIR","vn"=>"VNM","vu"=>"VUT","wf"=>"WLF","ws"=>"WSM","ye"=>"YEM","yt"=>"MYT","za"=>"ZAF","zm"=>"ZMB","zw"=>"ZWE"};
	my $fake   = $self->{ faker };
	my $uuid   = UUID::uuid();
	my $gender = $login->{ _gender };
	my $dob    = $login->{ _dob };
	my $fname  = $login->{ _fname };
	my $lname  = $login->{ _lname };
	my $id     = sprintf( '0%d%6d', int( rand() * 9 ) + 1, int( rand() * 999999 ));
	my $rank   = _rank_history( $dob );
	my $code2  = lc((split /\./, $email)[ -1 ]);
	my $noc    = exists $codes->{ $code2 } ? $codes->{ $code2 } : 'usa';
	my $json   = new JSON::XS();

	return {
		uuid   => $uuid,
		id     => $id,
		fname  => $fname,
		lname  => $lname,
		login  => $login->{ uuid },
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
sub _date {
# ============================================================
	my $date = new Date::Manip::Date( 'now' );
	$date->convert( 'utc' );
	return $date;
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
sub _ordinal {
# ============================================================
	my $num   = shift;
	my $d1 = $num % 10;
	my $d2 = $num % 100;
	if( $d1 == 1 && $d2 != 11 ) { return $num . 'st'; }
	if( $d1 == 2 && $d2 != 12 ) { return $num . 'nd'; }
	if( $d1 == 3 && $d2 != 13 ) { return $num . 'rd'; }
	return $num . 'th';
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

1;
