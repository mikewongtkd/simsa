#! /usr/bin/perl

use Data::Dumper;
use lib qw( lib );
use Shinsa;

my $examinee = Shinsa::Examinee->read( 'F96C6C3F-3E6F-4E28-906F-30CC623133E3' );

printf "%s %s\n", $examinee->fname(), $examinee->lname();

print Dumper $examinee->exam();

# ============================================================
my $exam = new Shinsa::Exam();

my $examinee = new Shinsa::Examinee(
	id   => 1,
	exam => $exam->uuid(),
	user => '5E5AED3D-9039-4C85-A305-FDD51FA62D0E'
);

# ============================================================
my $login = Shinsa::Login->read( '4FE052D1-3443-460C-8071-108079D7D9A9' );
my $user  = $login->users();

print Dumper $user;

# ============================================================
my $user = Shinsa::User->read( '5E5AED3D-9039-4C85-A305-FDD51FA62D0E' );

my $login = $user->login();
print 'Login ', $login->verify( 'password1234' ) ? 'OK' : 'Failed', "\n";

exit();
# ============================================================
my $login = new Shinsa::Login( 
	email => 'mikewongtkd@gmail.com',
	password => 'password1234'
);
my $user = new Shinsa::User();
$user->fname( 'Mike' );
$user->lname( 'Wong' );
$user->login( $login );
$user->write();
