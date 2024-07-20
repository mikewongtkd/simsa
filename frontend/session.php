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
}

$session = new Session();
date_default_timezone_set( 'UTC' );
?>
