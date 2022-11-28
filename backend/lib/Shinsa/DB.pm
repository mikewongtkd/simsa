package Shinsa::DB;
use DBI;
use UUID;
use List::Util qw( any );
use JSON::XS;

# ============================================================
sub new {
# ============================================================
	my ($class) = map { ref || $_ } shift;
	my $self = bless {}, $class;
	$self->init( @_ );
	return $self;
}

# ============================================================
sub init {
# ============================================================
	my $self      = shift;
	my $file      = undef;
	my @locations = qw( db.sqlite /usr/local/shinsa/db.sqlite );

	$self->{ cache } = { schema => {}};
	foreach $file (@locations) { next unless -e $file; }

	die "Database not found $!" unless $file;

	$self->{ dbh } = DBI->connect( "dbi:SQLite:dbname=$file" );
}

# ============================================================
sub delete {
# ============================================================
	my $self  = shift;
	my $table = shift;
	my $uuid  = shift;
	my $sth   = $self->handle();

	die "No row in table $table with uuid $uuid $!" unless $self->has( $table, $uuid );

	$sth->prepare( "delete from $table where uuid='$uuid'" );
	$sth->execute();

	my $rows = $self->select( $table, "uuid='$uuid'" );
	die "Row with uuid $uuid in table still exists after deleting $!" if $self->has( $table, $uuid );

	return 1;
}

# ============================================================
sub handle {
# ============================================================
	my $self = shift;

	die "No connection to database $!" unless exists $self->{ dbh };
	return $self->{ dbh };
}

# ============================================================
sub has {
# ============================================================
	my $self  = shift;
	my $table = shift;
	my $uuid  = shift;

	my $rows = $self->select( $table, "uuid='$uuid'" );

	return int( @$rows ) > 0;
}

# ============================================================
sub insert {
# ============================================================
# ( table, values ) where values is a hashref or arrayref
# ( table, fields, values ) where fields and values are strings
# ------------------------------------------------------------
	my $self   = shift;
	my $table  = shift;
	my $fields = shift;
	my $values = shift;
	my $dbh    = $self->handle();

	if( not defined $values ) {
		$values = $fields;
		$fields = [];
	}

	if( ref $values eq 'HASH' ) {
		my $schema = $self->schema( $table );
		my $type   = {};
		my $fields = [];
		foreach my $field (@$schema) {
			next unless( exists $values->{ $field->{ name }});
			$type->{ $field->{ name }} = $field->{ type };
			push @$fields, $field->{ name };
		}
		if( int( @$fields ) == 0 ) {
			my $json   = new JSON::XS();
			my $insert = $json->canonical->encode( $values );
			die "No valid fields provided for insert $insert $!";
		}
		unless( exists $values->{ uuid }) {
			unshift @$fields, 'uuid';
			$values->{ uuid } = $self->uuid();
		}
		$values = join( ', ', map { _sanitize( $values->{ $_ }, $type->{ $_ }) } @$fields );

	} elsif( ref $values eq 'ARRAY' ) {
		my $fields = [ map { $_->{ name } } $self->schema( $table )];
		unless( int( @$fields ) == int( @$values )) {
			my $json   = new JSON::XS();
			my $insert = $json->canonical->encode( $values );
			die "Incorrect number of fields provided for insert $insert $!";
		}
		$values = join( ', ', @$values );
	}

	$fields = join( ', ', @$fields ) if ref $fields eq 'ARRAY';
	$fields = $fields =~ /^\(/ && $fields =~ /\)$/ ? "( $fields )" : $fields;
	my $sth = $dbh->prepare( "insert into $table $fields values $values" );
	$sth->execute();
	
	my $rowid = $dbh->sqlite_last_insert_rowid();
	my $rows  = $self->select( $table, "rowid=$rowid" );

	return $rows->[ 0 ];
}

# ============================================================
sub schema {
# ============================================================
	my $self   = shift;
	my $table  = shift;

	return $self->{ cache }{ schema }{ $table } if( exists $self->{ cache }{ schema }{ $table });

	my $rows   = $self->select( 'sqlite_master', "type='table' and tbl_name='$table'" ); die "No table named '$table' found $!" unless int( @$rows ) > 0;
	my $row    = $rows->[ 0 ];
	my $schema = $row->{ sql };
	my $fields = $schema =~ /\((.*)\)/ms;

	$fields    = [ split /,\s*/ms, $fields ];
	$fields    = [ map { my ($name, $type, @modifiers) = split /\s+/; { name => $name, type => $type, modifiers => join( ' ', @modifiers )}} @$fields ];

	$self->{ cache }{ schema }{ $table } = $fields;

	return $fields;
}

# ============================================================
sub select {
# ============================================================
	my $self  = shift;
	my $table = shift;
	my $where = shift;
	my $dbh   = $self->handle();

	$where = $where ? " where $where" : '';

	my $sth = $dbh->prepare( "select * from $table $where" );
	$sth->execute();
	my $rows = $sth->fetchall_hashref();

	return $rows;
}

# ============================================================
sub update {
# ============================================================
# ( table, values, where ) where values is a hashref
# ------------------------------------------------------------
	my $self   = shift;
	my $table  = shift;
	my $values = shift;
	my $where  = shift;
	my $dbh    = $self->handle();

	die "Invalid argument to update; must be a hashref" unless( ref $values eq 'HASH' );
	my $schema = $self->schema( $table );
	my $fields = [];
	my $type   = {};
	foreach my $field (@$schema) {
		my $name = $field->{ name };
		next unless( exists $values->{ $name });
		push @$fields, $name;
		$type->{ $name } = $field->{ type };
	}
	if( int( @$fields ) == 0 ) {
		my $json   = new JSON::XS();
		my $insert = $json->canonical->encode( $values );
		die "No valid fields provided for insert $insert $!";
	}

	if( exists $values->{ uuid }) {
		my $uuid = $values->{ uuid };
		delete $values->{ uuid };

		if( defined $where && $where !~ /\buuid\b/ ) {
			$where = "$where and uuid='$uuid'";
			
		} else {
			$where = "uuid='$uuid'";
		}
	}

	$values = join( ', ', map { my $value = _sanitize( $values->{ $_ }, $type->{ $_ }); "$_=$value" } @$fields );
	$where  = $where ? " where $where" : '';

	my $sth = $dbh->prepare( "update $table set $values $where" );
	$sth->execute();
	
	my $rows = $self->select( $table, $where );

	return $rows;
}

# ============================================================
sub uuid {
# ============================================================
	my $self = shift;
	
	# Retrieve all tables that use UUIDs
	my $rows   = $self->select( 'sqlite_master', "type='table'" );
	my $tables = [];
	foreach my $row (@$rows) {
		next unless( $row->{ sql } =~ /\buuid\b/ );
		push @$tables, $row->{ name };
	}

	# Generate a new UUID and ensure that it's not redundant
	my $redundant = 0;
	my $limit     = 10;
	my $uuid;

	for( 0 .. $limit ) {
		$uuid      = UUID::uuid();
		$redundant = any { $self->has( $_, $uuid ) } @$tables;
		last unless $redundant;
	}

	return $uuid;
}

# ============================================================
sub _sanitize {
# ============================================================
	my $value = shift;
	my $type  = shift;

	if( $type =~ /^text/i ) {
		if( ref $value ) {
			my $json = new JSON::XS();
			$value   = $json->canonical->encode( $value );
		}
		$value =~ s/'/''/g;
		return "'$value'";

	} else {
		return $value;
	}
}

1;
