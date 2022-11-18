<?php

ini_set( 'session.save_handler', 'sqlite' );
ini_set( 'session.save_path', '/usr/local/shinsa/db.sqlite' );

session_name( 'shinsa-session' );
session_start();
date_default_timezone_set( 'UTC' );

?>
