use lib qw( lib );
use Shinsa::Schema;
use Shinsa::DataModel::Faker;
use UUID;
use JSON::XS();

my $json    = new JSON::XS();
my $fake    = new Shinsa::DataModel::Faker;
my $schema  = Shinsa::Schema->connect( 'dbi:SQLite:db.sqlite' );

# ===== LOGINS AND USERS
my $logins  = [];
my $users   = [];
for my $i ( 0 .. 100 ) {
	my $login = $fake->login();
	my $user  = $fake->user( $login );
	push @$logins, [ @$login{ qw( uuid email pwhash )} ];
	push @$users,  [ @$user{ qw( uuid id fname lname login dob gender rank noc )} ];

}

# ===== EXAMINATION
my $examination = $fake->examination( $users->[ 0 ]);

# ===== EXAMINERS
my $examiners = [];
for my $i ( 1 .. 10 ) {
	my $user     = $users->[ $i ];
	my $examiner = $fake->examiner( $user, $examination );
}

# ===== COHORTS AND EXAMINEES
my $ranks     = {};
my $examinees = [];
foreach my $user (@$users) {
	my ($highest) = sort { $b->{ rank } <=> $a->{ rank } } @{$user->{ rank }};
	push @{$ranks->{ $highest->{ rank }}}, $user;
}

foreach my $rank (sort keys %$ranks) {
	my $users = $ranks->{ $rank };
}

$schema->populate( 'Login',       [[ qw( uuid email pwhash )], @$logins ]);
$schema->populate( 'User',        [[ qw( uuid id fname lname login dob gender rank noc )], @$users ]);
$schema->populate( 'Examination', [[ qw( uuid name poster host address start description url )], @$examination{ qw( uuid name poster host address start description url )}]);

