package Shinsa::DBO;
use base qw( Clone );
use Data::Dumper;
use Data::Structure::Util qw( unbless );
use DBI;
use JSON::XS;
use Lingua::EN::Inflexion qw( noun verb );
use List::Util qw( any );
use UUID;
use vars '$AUTOLOAD';

our $dbh  = undef;
our $json = new JSON::XS();

# ============================================================
sub new {
# ============================================================
	my ($class) = map { ref || $_ } shift;
	my $table   = _class( $class );
	my $self    = bless {}, $class;

	my $n = int( @_ );

	if( $n == 0 ) {
		$self->{ uuid }  = UUID::uuid();
		$self->{ class } = $table;
		$self->{ data }  = {};

		warn "Extra parameters when initiating $class were ignored $!" if( $n > 2 );

	} elsif( $n == 1 ) {
		my $uuid = shift;
		return _get( $uuid ) if( _exists( $uuid ));

		$self->{ uuid }  = $uuid;
		$self->{ class } = $table;
		$self->{ data }  = {};

	} elsif( $n > 2 ) { 
		$self->{ uuid }  = UUID::uuid();
		$self->{ class } = $table;
		$self->{ data }  = { @_ };
	}

	$self->write();
	return $self;
}

# ============================================================
sub get {
# ============================================================
	my $self  = shift;
	my $query = shift;

	$query = _class( $query );

	if( $query eq 'DESTROY' ) {
		$self->SUPER::DESTROY();
		return;
	}

	my $plural = noun( $query )->is_plural;
	my $key    = $plural ? noun( $query )->singular : $query;

	# ===== RETURN DATA OR INTERNAL REFRENCE IF IT EXISTS
	if( exists $self->{ data }{ $key }) {
		my $results = $self->{ data }{ $key };

		# ===== IF REQUESTED AS A PLURAL, RETURN AN ARRAY
		if( $plural ) {
			if( ref $results eq 'ARRAY' ) {
				if( any { _is_uuid( $_ ) } @$results ) {
					return [ map { _is_uuid( $_ ) ? _get( $_ ) : $_ } @$results ];
				}
				return $results;

			} else {
				$results = _get( $results ) if( _is_uuid( $results ));
				return [ $results ];
			}

		# ===== IF REQUESTED AS SINGULAR, RETURN AN A SINGLE VALUE OR DOCUMENT
		} else {
			$results = shift @$results if( ref $results eq 'ARRAY' );
			$results = _get( $results ) if( _is_uuid( $results ));
			return $results;
		}

	# ===== RETURN EXTERNAL REFRENCE IF THEY EXISTS
	} else {
		my $mine       = ucfirst( $key );
		my $ref        = lc _class( ref $self );
		my $me         = $self->uuid();
		my $references = _find_references( $mine, $ref, $me );

		if( int( @$references ) == 0 ) {
			warn "Key $key not in $self->{ class } object $!";
			return;

		} elsif( $plural ) {
			return $references;

		} else {
			return shift @$references;
		}
	}
}

# ============================================================
sub read {
# ============================================================
	my $class = shift;
	my $uuid  = shift;
	return _get( $uuid );
}

# ============================================================
sub set {
# ============================================================
	my $self   = shift;
	my $key    = shift;
	my $value  = shift;
	my $ref    = ref $value;
	my $plural = noun( $key )->is_plural;

	$key = noun( $key )->is_plural ? noun( $key )->singular : $key;

	if((! $ref) || $ref eq 'HASH' || $ref eq 'ARRAY' ) {
		$self->{ data }{ $key } = $value;
	} elsif( $value->can( 'uuid' )) {
		$self->{ data }{ $key } = $value->uuid();
	}
}

# ============================================================
sub uuid {
# ============================================================
	my $self = shift;
	return $self->{ uuid };
}

# ============================================================
sub write {
# ============================================================
	my $self   = shift;
	my $clone  = $self->clone();
	my $uuid   = $clone->uuid();
	my $exists = _exists( $uuid );

	delete $clone->{ uuid }; # Remove UUID prior to pruning
	
	$clone = unbless( $clone );
	$clone = _prune( $clone );

	$clone->{ uuid } = $uuid; # Add UUID back in prior to writing to DB

	if( $exists ) {
		_update( $clone );
	} else {
		_put( $clone );
	}
}

# ============================================================
sub AUTOLOAD {
# ============================================================
	my $self   = shift;
	my $n      = int( @_ );

	if( $n == 1 ) {
		my $value = shift;
		my $field = _class( $AUTOLOAD );
		$self->set( $field, $value );

	} elsif( $n > 1 ) {
		warn "Extra parameters to $AUTOLOAD were ignored $!";

	} else {
		return $self->get( $AUTOLOAD );
	}
}

# ============================================================
sub _class {
# ============================================================
	my $class = shift;
	$class = (split /::/, $class)[ -1 ];
	return $class;
}

# ============================================================
sub _db_connect {
# ============================================================
	$Shinsa::DBO::dbh = DBI->connect( 'DBI:SQLite:dbname=db.sqlite' ) if( ! defined $Shinsa::DBO::dbh );
}

# ============================================================
sub _exists {
# ============================================================
	_db_connect();
	my $uuid  = shift;
	my $sth   = $Shinsa::DBO::dbh->prepare( 'select count(*) from document where uuid=?' );
	$sth->execute( $uuid );

	my $count = $sth->fetchrow_arrayref();
	$count = int( $count->[ 0 ]);


	return $count;
}

# ============================================================
sub _factory {
# ============================================================
	my $document = shift;
	my $class    = sprintf( "Shinsa::%s", ucfirst $document->{ class });
	my $data     = $json->decode( $document->{ data });
	my $result   = bless { uuid => $document->{ uuid }, class => $document->{ class }, data => $data }, $class;

	return $result;
}

# ============================================================
sub _find_references {
# ============================================================
	_db_connect();
	my $mine  = shift;
	my $ref   = shift;
	my $me    = shift;

	# ===== SEARCH FOR DIRECT REFERENCES
	# Things that are mine that refer back to me
	my $sth   = $Shinsa::DBO::dbh->prepare( "select * from document where class=? and json_extract( document.data, ? ) = ?" );
	$sth->execute( $mine, "\$.$ref", $me );

	my $results = [];

	while( my $document = $sth->fetchrow_hashref()) {
		push @$results, _factory( $document );
	}

	# ===== SEARCH FOR REFERENCES IN JOIN DOCUMENTS
	# Joins that refer to me and have things that are mine
	my $sth   = $Shinsa::DBO::dbh->prepare( "select * from document where class='Join' and json_extract( document.data, ? ) = ? and json_extract( document.data, ? ) is not null" );
	$sth->execute( "\$.$ref", $me, "\$.$mine" );

	while( my $document = $sth->fetchrow_hashref()) {
		push @$results, _factory( $document );
	}

	return $results;
}

# ============================================================
sub _get {
# ============================================================
	_db_connect();
	my $uuid   = shift;
	my $exists = _exists( $uuid );

	if( ! $exists ) {
		warn "No document with UUID $uuid $!";
		return undef;
	}

	my $sth    = $Shinsa::DBO::dbh->prepare( 'select * from document where uuid=?' );
	$sth->execute( $uuid );

	my $document = $sth->fetchrow_hashref();
	return _factory( $document );
}

# ============================================================
sub _put {
# ============================================================
	_db_connect();
	my $document = shift;
	my $uuid     = $document->{ uuid };
	my $class    = $document->{ class };
	my $data     = $json->canonical->encode( $document->{ data });

	my $sth      = $Shinsa::DBO::dbh->prepare( 'insert into document (uuid, class, data) values (?, ?, ?)' );
	$sth->execute( $uuid, $class, $data );
}

# ============================================================
sub _prune {
# ============================================================
	my $document = shift;
	my $type     = ref $document;

	# SCALAR
	if( $type eq '' ) { return $document }

	# ARRAY
	if( $type eq 'ARRAY' ) {
		@$document = map { _prune( $_ ) } @$document;
		return $document;
	}

	# HASH
	if( $type eq 'HASH' ) {
		if( exists( $document->{ uuid })) {
			return $document->{ uuid };
		} else {
			return { map { $_ => _prune( $document->{ $_ })} sort keys %$document };
		}
	}
}

# ============================================================
sub _update {
# ============================================================
	_db_connect();
	my $document = shift;
	my $uuid     = $document->{ uuid };
	my $data     = $json->canonical->encode( $document->{ data });

	my $sth      = $Shinsa::DBO::dbh->prepare( 'update document set data=? where uuid=?' );
	$sth->execute( $data, $uuid );
}

# ============================================================
sub _is_uuid {
# ============================================================
	my $value = shift;
	return 0 if ref $value;
	return $value =~ /^[0-9A-Fa-f]{8}\-[0-9A-Fa-f]{4}\-[0-9A-Fa-f]{4}\-[0-9A-Fa-f]{4}\-[0-9A-Fa-f]{12}$/;
}

1;
