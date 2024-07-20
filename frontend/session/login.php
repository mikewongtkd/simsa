<?php
$email  = $_POST[ 'email' ];
$pword  = $_POST[ 'password' ];

$db     = new SQLite3( '/usr/local/simsa/db.sqlite' );
$login  = $db->querySingle( "select json_extract( data, '$.email' ) as email and json_extract( data, '$.pwhash' ) as pwhash from document where class = 'login' and email = '$email'" );
$pwhash = $login[ 'pwhash' ];

if( password_verify( $pword, $pwhash )) {
	$_SESSION[ 'auth' ] = true;
	header( 'Location: index.php' );
} else {
	$_SESSION[ 'auth' ] = false;
	$message = base64_encode( 'Username and password do not match our records' );
	header( "Location: index.php?error=$message" );
}
exit();

?>
<!-- vim: set ts=2 sw=2 expandtab :-->
