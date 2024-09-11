#! /usr/bin/perl

use Data::Dumper;
use lib qw( lib );
use Simsa;

my $login = new Simsa::Login( 
	email => 'mikewongtkd@gmail.com',
	password => 'password1234'
);
my $user = new Simsa::User();
$user->fname( 'Mike' );
$user->lname( 'Wong' );
$user->grant_root_access();
$user->login( $login );

print 'Login ', $login->verify( 'password1234' ) ? 'OK' : 'Failed', "\n";

foreach my $user ($login->users()) {
	printf "%s %s uses this login.\n", $user->fname(), $user->lname();
}

my $exam = new Simsa::Exam( name => 'CUTA KKW Dan Examination', date => '2024-10-05', location => 'Sparta Taekwondo' );

my $examinee = new Simsa::Role::Examinee(
	id   => '101',
	exam => $exam->uuid(),
	user => $user->uuid(),
	promoting => { to => '7th Dan', from => '6th Dan' }
);

printf "Examinee: %d -> %s %s\n\n", $examinee->id(), $examinee->fname(), $examinee->lname();

print map { $examinee->exam->$_() . "\n" } qw( name location date );

print map { sprintf( "%-4s %-20s %-30s %-18s %s\n", $_->id(), join( ', ', $_->roles ), $_->login->email(), $_->lname(), $_->fname()) }  $exam->examinees();

