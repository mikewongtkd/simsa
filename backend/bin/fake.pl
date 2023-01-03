use lib qw( lib );
use Shinsa::Schema;
use Shinsa::DataModel::Faker;
use UUID;
use JSON::XS();

my $json   = new JSON::XS();
my $fake   = new Shinsa::DataModel::Faker;
my $schmea = Shinsa::Schema->connect( 'dbi:SQLite:db.sqlite' );

for my $i ( 0 .. 99 ) {
	my $user = $fake->user();
	$user->{ id } = UUID::uuid();
}
