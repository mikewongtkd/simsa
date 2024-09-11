<?php
include_once( __DIR__ . '/../session.php' );

global $session;
$email  = $_POST[ 'email' ];
$pword  = $_POST[ 'password' ];

if( $session->login( $email, $pword )) {
	header( 'Location: index.php' );

} else {
	$message = base64_encode( 'Username and password do not match our records' );
	header( "Location: index.php?error=$message" );
}
exit();

?>
<!-- vim: set ts=2 sw=2 expandtab :-->
