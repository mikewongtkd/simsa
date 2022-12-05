use lib qw( lib );
use Shinsa::DataModel::Faker;
use JSON::XS();

my $json = new JSON::XS();
my $fake = new Shinsa::DataModel::Faker;

print $json->canonical->pretty->encode( $fake->user());
