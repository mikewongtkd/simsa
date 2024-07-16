#! /usr/bin/perl

use lib qw( lib );
use List::Util qw( sum );
use Simsa;
use Simsa::DataModel::Faker;
use Text::CSV qw( csv );
use UUID;
use JSON::XS();

my $json    = new JSON::XS();
my $fake    = new Simsa::DataModel::Faker;
my $schema  = Simsa::Schema->connect( 'dbi:SQLite:db.sqlite' );
my $count   = {
	panel     => { size => 5 },
	panels    => 2,
	examiners => 10,
	examinees => 100,
	officials => 0,
	group     => { size => 5 }
};

$count->{ staff } = sum @{$count{ qw( examiners officials )}};
$count->{ users } = sum @{$count{ qw( staff examinees )}};

# ===== LOGINS AND USERS
my $logins  = [];
my $users   = [];
for my $i ( 0 .. $count->{ users }) {
	my $login = $fake->login();
	my $user  = $fake->user( $login );

	$login = new Simsa::Login( %$login );
	$user  = new Simsa::User( %$user );

	$login->write();
	$user->write();

	push @$logins, [ @$login{ qw( uuid email pwhash )} ];
	push @$users,  [ @$user{ qw( uuid id fname lname login dob gender rank noc )} ];
}

my $producer = $users->[ 0 ];

# ===== EXAM
my $exam = $fake->exam( $producer );
$exam = new Simsa::Exam( %$exam );
$exam->write();

# ===== EXAMINERS AND PANELS
my ($examiners, $panels, $panel_examiners) = $fake->group_examiners_into_panels( $users, $exam, $count );

$schema->populate( 'Examiner',      [[ qw( uuid user exam )], @$examiners ]);
$schema->populate( 'Panel',         [[ qw( uuid exam name )], @$panels ]);
$schema->populate( 'PanelExaminer', [[ qw( uuid panel examiner start stop )], @$panel_examiners ]);

# ===== EXAMINEES AND GROUPS
my ($examinees, $groups) = $fake->group_examinees_into_groups( $users, $exam, $count );
$schema->populate( 'Cohort',   [[ qw( uuid exam panel location name description parent )];
$schema->populate( 'Examinee', [[ qw( uuid user exam id group )], @$examinees ]);


