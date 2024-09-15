package Simsa::DBO;
use base qw( Clone );
use Data::Dumper;
use Data::Structure::Util qw( unbless );
use DBI;
use JSON::XS;
use Lingua::EN::Inflexion qw( noun verb );
use List::Util qw( any all );
use UUID;
use vars '$AUTOLOAD';

our $dbh  = undef;
our $sth  = {};
our $json = new JSON::XS();
our $statement = {
	delete     => "update document set deleted = datetime( 'now' ) where uuid=? and deleted is null",
	exists     => 'select count(*) from document where uuid=? and deleted is null',
	get        => 'select * from document where uuid=? and deleted is null',
	insert     => 'insert into document (uuid, class, data) values (?, ?, ?)',
	joins      => "select * from document where class='Join' and json_extract( document.data, ? ) = ? and json_extract( document.data, ? ) is not null",
	references => "select * from document where class like ? and json_extract( document.data, ? ) = ?",
	restore    => 'update document set deleted = null where uuid=?',
	update     => "update document set data=?, modified = datetime( 'now' ) where uuid=?"
};

# ============================================================
sub new {
# ============================================================
	my ($class) = map { ref || $_ } shift;
	my $table   = _class( $class );
	my $self    = bless {}, $class;
	my $n       = int( @_ );

	my $guuid   = _generate_uuid();

	if( $n == 0 ) {
		$self->{ uuid }  = $guuid;
		$self->{ class } = $table;
		$self->{ data }  = {};

		warn "Extra parameters when initiating $class were ignored $!" if( $n > 2 );

	} elsif( $n == 1 ) {
		my $uuid = shift;
		return _get( $uuid ) if( _exists( $uuid ));

		$self->{ uuid }  = $uuid;
		$self->{ class } = $table;
		$self->{ data }  = {};

	} elsif( $n > 1 ) { 
		$self->{ uuid }  = $guuid;
		$self->{ class } = $table;
		$self->{ data }  = { @_ };
		$self->{ uuid }  = $self->{ data }{ uuid } if( exists $self->{ data }{ uuid });
	}

	$self->write();
	return $self;
}

# ============================================================
sub class {
# ============================================================
	my $self = shift;
	return $self->{ class };
}

# ============================================================
sub document {
# ============================================================
	my $self   = shift;
	my $clone  = $self->clone();
	my $uuid   = $clone->uuid();

	delete $clone->{ uuid }; # Remove UUID prior to pruning
	
	$clone = unbless( $clone );
	$clone = _prune( $clone );

	$clone->{ uuid } = $uuid; # Add UUID back in prior to writing to DB

	return $clone;
}

# ============================================================
sub get {
# ============================================================
	my $self   = shift;
	my $query  = shift;
	my $filter = shift;

	$query = _field( $query );

	if( $query eq 'DESTROY' ) {
		$self->SUPER::DESTROY();
		return;
	}

	my $plural = noun( $query )->is_plural;
	my $key    = lc( $plural ? noun( $query )->singular : $query );

	# ===== RETURN DATA OR INTERNAL REFERENCE IF IT EXISTS
	# Internal references are provided within the data (e.g. belongs-to relationships)
	if( exists $self->{ data }{ $key }) {
		my $results = $self->{ data }{ $key };

		# ===== IF REQUESTED AS A PLURAL, RETURN AN ARRAY
		if( $plural ) {
			if( ref $results eq 'ARRAY' ) {
				if( any { _is_uuid( $_ ) } @$results ) {
					@$results = map { _is_uuid( $_ ) ? _get( $_ ) : $_ } @$results;
				}
				_filter( $results, $filter );
				return @$results;

			} else {
				$results = _get( $results ) if( _is_uuid( $results ));
				return ( $results );
			}

		# ===== IF REQUESTED AS SINGULAR, RETURN AN A SINGLE VALUE OR DOCUMENT
		} else {
			$results = shift @$results if( ref $results eq 'ARRAY' );
			$results = _get( $results ) if( _is_uuid( $results ));
			return $results;
		}

	# ===== RETURN EXTERNAL REFERENCE IF THEY EXISTS
	# External references are provided by documents that have the current class
	# as a field
	} else {
		my $mine       = ucfirst( $key );
		my $ref        = lc _field( ref $self );
		my $me         = $self->uuid();
		my $references = _find_references( $mine, $ref, $me );

		if( $plural ) {
			return @$references;

		} else {
			return if( int( @$references ) == 0 );
			return shift @$references;
		}
	}

	return undef;
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
	$self->write();
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
	my $doc    = $self->document();
	my $uuid   = $self->uuid();
	my $exists = _exists( $uuid );

	if( $exists ) {
		_update( $doc );
	} else {
		_put( $doc );
	}
}

# ============================================================
sub AUTOLOAD {
# ============================================================
	my $self   = shift;
	my $n      = int( @_ );

	if( $n == 1 ) {
		my $value = shift;
		my $field = _field( $AUTOLOAD );
		$self->set( $field, $value );

	} elsif( $n > 1 ) {
		if( $_[ 0 ] eq 'where' ) {
			my $filter = $_[ 1 ];
			return $self->get( $AUTOLOAD, $filter );

		} else {
			warn "Extra parameters to $AUTOLOAD were ignored $!";
		}

	} else {
		return $self->get( $AUTOLOAD );
	}

	return;
}

# ============================================================
sub _class {
# ============================================================
	my $class = shift;
	my @namespaces = grep { ! /^Simsa$/ } split /::/, $class;

	$class = join( '::', @namespaces );
	return $class;
}

# ============================================================
sub _db_connect {
# ============================================================
	$Simsa::DBO::dbh = DBI->connect( 'dbi:SQLite:db.sqlite' ) if( ! defined $Simsa::DBO::dbh );
}

# ============================================================
sub _exists {
# ============================================================
	_db_connect();
	my $uuid  = shift;
	my $sth   = _prepared_statement( 'exists' );
	$sth->execute( $uuid );

	my $count = $sth->fetchrow_arrayref();
	$count = int( $count->[ 0 ]);

	return $count;
}

# ============================================================
sub _factory {
# ============================================================
	my $document = shift;
	my $class    = sprintf( "Simsa::%s", $document->{ class });
	my $data     = $json->decode( $document->{ data });
	my $result   = bless { uuid => $document->{ uuid }, class => $document->{ class }, data => $data }, $class;

	return $result;
}

# ============================================================
sub _field {
# ============================================================
	my $field = shift;
	$field = (split /::/, $field)[ -1 ];
	return $field;
}

# ============================================================
sub _filter {
# ============================================================
	my $results = shift;
	my $filter  = shift;

	return $results unless $filter;

	foreach my $field (keys %$filter) {
		my $uuid = _uuid( $filter->{ $field });
		@$results = grep { 
			my $ref = ref( $_ );
			return 0 unless $ref && $ref ne 'ARRAY' && exists $ref->{ data } && exists $ref->{ data }{ $field };
			return _uuid( $ref->{ data }{ $field }) eq $uuid;
		} @$results;
	}

	return $results;
}

# ============================================================
sub _find_references {
# ============================================================
	_db_connect();
	my $mine  = shift;
	my $refer = shift;
	my $me    = shift;

	# ===== SEARCH FOR DIRECT REFERENCES
	# Things that are mine that refer back to me
	# (i.e. has-one relationships)
	my $sth = _prepared_statement( 'references' );
	$sth->execute( "%$mine", "\$.$refer", $me );

	my $results = [];

	while( my $document = $sth->fetchrow_hashref()) {
		push @$results, _factory( $document );
	}

	# ===== SEARCH FOR REFERENCES IN JOIN DOCUMENTS
	# Joins that refer to me and have things that are mine
	# (i.e. more complicated relationships, including: many-to-many)
	my $sth = _prepared_statement( 'joins' );
	$sth->execute( "\$.$refer", $me, "\$.$mine" );

	while( my $document = $sth->fetchrow_hashref()) {
		push @$results, _factory( $document );
	}

	return $results;
}

# ============================================================
sub _generate_uuid {
# ============================================================
	my $attempts = 0;
	my $uuid     = lc UUID::uuid();
	while( _exists( $uuid ) && $attempts < 100 ) { $uuid = lc UUID::uuid(); $attempts++; }

	die "Unable to create a unique UUID $!" if( $attempts >= 100 );

	return $uuid;
}

# ============================================================
sub _get {
# ============================================================
	_db_connect();
	my $uuid   = shift;
	my $exists = _exists( $uuid );

	return $uuid if ref $uuid;

	if( ! $exists ) {
		warn "No document with UUID $uuid $!";
		return undef;
	}

	my $sth = _prepared_statement( 'get' );
	$sth->execute( $uuid );

	my $document = $sth->fetchrow_hashref();
	return _factory( $document );
}

# ============================================================
sub _prepare_statement {
# ============================================================
	my $name = shift;
	my $sql  = shift;
	die "System-defined prepared statement named '$name' already exists $!" if exists $Simsa::DBO::statement->{ $name };

	# Return Singleton if exists and defined
	return $Simsa::DBO::sth->{ $name } if exists $Simsa::DBO::sth->{ $name } && $Simsa::DBO::sth->{ $name };

	# Else prepare the statement handle and return
	return $Simsa::DBO::sth->{ $name } = $Simsa::DBO::dbh->prepare( $sql );
}

# ============================================================
sub _prepared_statement {
# ============================================================
	my $name = shift;
	die "No prepared statement named '$name' $!" unless exists $Simsa::DBO::statement->{ $name };

	# Return Singleton if exists and defined
	return $Simsa::DBO::sth->{ $name } if exists $Simsa::DBO::sth->{ $name } && $Simsa::DBO::sth->{ $name };

	# Else prepare the statement handle and return
	return $Simsa::DBO::sth->{ $name } = $Simsa::DBO::dbh->prepare( $Simsa::DBO::statement->{ $name });
}

# ============================================================
sub _put {
# ============================================================
	_db_connect();
	my $document = shift;
	my $uuid     = $document->{ uuid };
	my $class    = $document->{ class };
	my $data     = $json->canonical->encode( $document->{ data });

	my $sth = _prepared_statement( 'insert' );
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
sub _search {
# ============================================================
	my %query = @_;

	my $sql    = 'select *, '
	my @select = map { "json_extract( data, \"\$.$_\" ) as $_" } keys %query;

	$sql .= join( ', ', @select );

	my @where  = map { "$_ like ?" } keys %query;

	$sql .= ' where ' . join( ' and ', @where ) . ' and deleted is null';
}

# ============================================================
sub _update {
# ============================================================
	_db_connect();
	my $document = shift;
	my $uuid     = $document->{ uuid };
	my $data     = $json->canonical->encode( $document->{ data });

	my $sth = _prepared_statement( 'update' );
	$sth->execute( $data, $uuid );
}

# ============================================================
sub _uuid {
# ============================================================
	my $document = shift;
	return $document if _is_uuid( $document );
	return $document->uuid();
}

# ============================================================
sub _is_uuid {
# ============================================================
	my $value = shift;
	return 0 if ref $value;
	return $value =~ /^[0-9A-Fa-f]{8}\-[0-9A-Fa-f]{4}\-[0-9A-Fa-f]{4}\-[0-9A-Fa-f]{4}\-[0-9A-Fa-f]{12}$/;
}

# ============================================================
sub DESTROY {
# ============================================================
	my $self = shift;
}

1;
