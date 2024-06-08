#! /usr/bin/perl

use Data::Dumper;
use lib qw( lib );
use Shinsa;

my $login = new Shinsa::Login( 
	email => 'mikewongtkd@gmail.com',
	password => 'password1234'
);
my $user = new Shinsa::User();
$user->fname( 'Mike' );
$user->lname( 'Wong' );
$user->login( $login );

print 'Login ', $login->verify( 'password1234' ) ? 'OK' : 'Failed', "\n";

my $exam = new Shinsa::Exam( name => 'CUTA KKW Dan Examination', date => '2024-10-05', location => 'Sparta Taekwondo' );

my $examinee = new Shinsa::Examinee(
	id   => 1,
	exam => $exam->uuid(),
	user => $user->uuid()
);

printf "%s %s\n", $examinee->fname(), $examinee->lname();

print Dumper $examinee->exam();

print Dumper $exam->examinees();

