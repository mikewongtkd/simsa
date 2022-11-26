package Shinsa::DB;
use DBI;
use UUID qw( uuid );

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

	foreach $file (@locations) { next unless -e $file; }

	die "Database not found $!" unless $file;

	$self->{ dbh } = DBI->connect( "dbi:SQLite:dbname=$file" );
}

# ============================================================
sub handle {
# ============================================================
	my $self = shift;

	die "No connection to database $!" unless exists $self->{ dbh };
	return $self->{ dbh };
}

# ============================================================
sub select {
# ============================================================
	my $self  = shift;
	my $dbh   = $self->handle();
	my $table = shift;
	my $where = shift;
	my $dbh   = $self->handle();

	$where = $where ? " where $where" : '';

	$dbh->prepare( "select * from $table $where" );
}

# ============================================================
sub uuid {
# ============================================================
	my $self = shift;
	
	# Retrieve all tables that use UUIDs
	my $sth = $self->select( 'sqlite_master', "type='table'" );
	$sth->execute();

	my $tables = [];
	my $rows   = $sth->fetchall_hashref();
	foreach my $row (@$rows) {
		next unless( $row->{ sql } =~ /\buuid\b/ );
		push @$tables, $row->{ name };
	}

	# Generate a new UUID and ensure that it's not redundant
	my $redundant = 0;
	my $uuid;

	do {
		$uuid = uuid();

		foreach my $table (@$tables) {
			my $sth = $self->select( $table, "uuid='$uuid'" );
			$sth->execute();
			my $rows = $sth->fetchall_hashref();
			$redundant = int( @$rows ) > 0;
		}
	} while( $redundant );

	return $uuid;
}

1;
