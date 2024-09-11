<?php

class Session
{
  private $db;

  public function __construct() {
      $this->db = new SQLite3( '/usr/local/simsa/db.sqlite' );

      session_name( 'simsa-session' );

      session_set_save_handler(
        [ $this, "_open" ],
        [ $this, "_close" ],
        [ $this, "_read" ],
        [ $this, "_write" ],
        [ $this, "_destroy" ],
        [ $this, "_gc" ]
      );

      session_start();
  }

  public function _open() {
    if( $this->db ) { return true; }
    return false;
  }

  public function _close() {
    if( $this->db->close()) { return true; }
    return false;
  }

  public function _read( $id ) {
    $row = $this->db->querySingle( "select data from sessions where id = '$id';" );
    if( $row ) {
      return $row[ 'data' ];
    } else {
      return "";
    }
  }

  public function _write( $id, $data ) {
    $seen   = time();
    $sth    = $this->db->prepare( "update sessions set seen = :seen, data = :data where id = :id" );
    $sth->bindParam( ':seen', $seen );
    $sth->bindParam( ':data', $data );
    $sth->bindParam( ':id', $id );

    if( $sth->execute()) { return true; }
    return false;
  }

  public function _destroy( $id ) {
    $sth    = $this->db->prepare( "delete from sessions where id = :id" );
    $sth->bindParam( ':id', $id );

    if( $sth->execute()) { return true; }
    return false;
  }

  public function _gc( $max ) {
    $old = time() - $max;
    $sth = $this->db->prepare( "delete from sessions where seen < :old");
    $sth->bindParam( ":old", $old );
    if ($this->db->execute()) { return true; }
    return false;
  }

  public function login( $username, $password ) {
    $login  = $this->db->querySingle( "select uuid, json_extract( data, '$.email' ) as email and json_extract( data, '$.pwhash' ) as pwhash from document where class = 'Login' and email = '$email'" );
    $pwhash = $login[ 'pwhash' ];
    $users  = $this->query( "select uuid, json_extract( data, '$.login' ) as login from document where class = 'User' and login = '{$login[ 'uuid' ]}'" );
    $users  = join( ', ', array_map( function ($user) { return "'{$user[ 'uuid' ]}'"; }, $users ));
    $roles  = $this->query( "select class, json_extract( data, '$.user' ) as user, json_extract( data, '$.exam' ) as exam from document where user in ({$users}) and exam is not null" );

    $exams  = [];
    foreach $roles as $role {
      $exam = $role[ 'exam' ];
      if( array_key_exists( $exam, $exams )) {
        if( array_search( $role[ 'class' ], $exams[ $exam ])) { continue; }
        array_push( $exams[ $exam ], $role[ 'class' ]);
      } else {
        $exams[ $exam ] = [ $role[ 'class' ]];
      }
    }

    if( password_verify( $password, $pwhash )) {
      $_SESSION[ 'exams' ] = $exams;
      return $_SESSION[ 'auth' ]  = true;

    } else {
      return $this->logout();
    }
  }

  public function logout() {
    $_SESSION[ 'exams' ] = [];
    $_SESSION[ 'auth' ]  = false;
    return false;
  }

  private function query( $query ) {
    $results = $this->db->query( $query );
    $rows    = [];
    while( $row = $results->fetchArray()) {
      array_push( $rows, $row );
    }
    return $rows;
  }
}

$session = new Session();
date_default_timezone_set( 'UTC' );
?>
