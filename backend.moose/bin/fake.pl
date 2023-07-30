use lib qw( lib );
use List::Util qw( sum );
use Shinsa::Schema;
use Shinsa::DataModel::Faker;
use UUID;
use JSON::XS();

my $json    = new JSON::XS();
my $fake    = new Shinsa::DataModel::Faker;
my $schema  = Shinsa::Schema->connect( 'dbi:SQLite:db.sqlite' );
my $count   = {
	panel     => { size => 5 },
	panels    => 2,
	examiners => 10,
	examinees => 100,
	officials => 0,
	cohort    => { size => 4 }
};

$count->{ staff } = sum @{$count{ qw( examiners officials )}};
$count->{ users } = sum @{$count{ qw( staff examinees )}};

# ===== LOGINS AND USERS
my $logins  = [];
my $users   = [];
for my $i ( 0 .. $count->{ users }) {
	my $login = $fake->login();
	my $user  = $fake->user( $login );
	push @$logins, [ @$login{ qw( uuid email pwhash )} ];
	push @$users,  [ @$user{ qw( uuid id fname lname login dob gender rank noc )} ];

}
my $poster = $users->[ 0 ];
$schema->populate( 'Login', [[ qw( uuid email pwhash )], @$logins ]);
$schema->populate( 'User',  [[ qw( uuid id fname lname login dob gender rank noc )], @$users ]);

# ===== EXAMINATION
my $examination = $fake->examination( $poster );
$schema->populate( 'Examination', [[ qw( uuid name poster host address start description url )], @$examination{ qw( uuid name poster host address start description url )}]);

# ===== EXAMINERS AND PANELS
my ($examiners, $panels, $panel_examiners) = $fake->group_examiners_into_panels( $users, $examination, $count );

$schema->populate( 'Examiner',      [[ qw( uuid user exam )], @$examiners ]);
$schema->populate( 'Panel',         [[ qw( uuid exam name )], @$panels ]);
$schema->populate( 'PanelExaminer', [[ qw( uuid panel examiner start stop )], @$panel_examiners ]);

# ===== EXAMINEES AND COHORTS
my ($examinees, $cohorts) = $fake->group_examinees_into_cohorts( $users, $examination, $count );
$schema->populate( 'Cohort',   [[ qw( uuid exam panel location name description parent )];
$schema->populate( 'Examinee', [[ qw( uuid user exam id cohort )], @$examinees ]);

