#! /usr/bin/perl

use Data::Dumper;
use lib qw( lib );
use Shinsa::DBO;
use Shinsa::Examination;
use Shinsa::Examinee;
use Shinsa::Examiner;
use Shinsa::Group;
use Shinsa::Login;
use Shinsa::Official;
use Shinsa::Panel;
use Shinsa::Schedule;
use Shinsa::Score;
use Shinsa::User;

my $user = Shinsa::User->read( '5E5AED3D-9039-4C85-A305-FDD51FA62D0E' );

my $login = $user->login();
print 'Login ', $login->verify( 'password1234' ) ? 'OK' : 'Failed', "\n";

exit();
my $login = new Shinsa::Login( 
	email => 'mikewongtkd@gmail.com',
	password => 'password1234'
);
my $user = new Shinsa::User();
$user->fname( 'Mike' );
$user->lname( 'Wong' );
$user->login( $login );
$user->write();
