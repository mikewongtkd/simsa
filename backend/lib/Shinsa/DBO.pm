package Shinsa::DBO;
use Clone qw( clone );
use DBI;
use JSON::XS;
use Lingua::EN::Inflexion qw( noun verb );
use List::Util qw( any );
use UUID qw( uuid );
use vars '$AUTOLOAD';

our $dbh = undef;

# ============================================================
sub new {
# ============================================================
	my ($class) = map { ref || $_ } shift;
	my $table   = _class( $class );
	my $self    = bless {}, $class;
	$Shinsa::DBO::dbh = DBI->connect( 'db.sqlite' ) if( ! defined $Shinsa::DBO::dbh );

	my $n = int( @_ );

	if( $n == 0 || $n > 2 ) {
		$self->{ uuid }  = uuid();
		$self->{ table } = $table;
		$self->{ data }  = {};

		warn "Extra parameters when initiating $class were ignored $!" if( $n > 2 );

	} elsif( $n == 1 ) {
		my $uuid = shift;
		$self->{ uuid }  = $uuid;
		$self->{ table } = $table;
		$self->{ data }  = {};

	} elsif( $n == 2 ) { 
		my $uuid = shift;
		my $data = shift;
		$self->{ uuid }  = $uuid;
		$self->{ table } = $table;
		$self->{ data }  = $data;
	}
	$self->write();

	return $self;
}

# ============================================================
sub get {
# ============================================================
	my $self  = shift;
	my $query = shift;

	my $plural = noun( $query )->is_plural;
	my $key    = $plural ? noun( $query )->singular : $query;

	return undef unless exists $self->{ data }{ $key };

	my $results = $self->{ data }{ $key };

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
	} else {
		$results = shift @$results if( ref $results eq 'ARRAY' );
		$results = _get( $results ) if( _is_uuid( $results ));
		return $results;
	}
}

# ============================================================
sub read {
# ============================================================
	my $uuid = shift;
	return _get( $uuid );
}

# ============================================================
sub write {
# ============================================================
	my $self = shift;
	_put( $self );
}

# ============================================================
sub AUTOLOAD {
# ============================================================
	my $self = shift;
	my $n    = int( @_ );

	if( $n == 1 ) {
		my $value = shift;
		$self->set( $AUTOLOAD, $value );

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
	$class =~ s/^Shinsa:://;
}

# ============================================================
sub _get {
# ============================================================
	my $uuid = shift;
	my $sth  = $Shinsa::DBO::dbh->prepare( 'select * from document where uuid=?' );
	my $json = new JSON::XS();
	$sth->execute( $uuid );

	if( $sth->rows == 0 ) {
		warn "No document with UUID $uuid $!";
		return undef;
	}

	my $document = $sth->fetchrow_hashref();
	my $class    = sprintf( "Shinsa::%s", ucfirst $document->{ class })
	my $data     = $json->decode( $document->{ data });
	my $result   = bless { uuid => $uuid, class => $document->{ class }, data => $data }, $class;

	return $result;
}

# ============================================================
sub _put {
# ============================================================
	my $document = shift;
	my $json     = new JSON::XS();
	my $uuid     = $document->{ uuid };
	my $class    = $document->{ class };
	my $data     = $json->canonical->encode( $document->{ data });

	my $sth      = $Shinsa::DBO::dbh->prepare( 'insert into document (uuid, class, data) values (?, ?, ?)' );
	$sth->execute( $uuid, $class, $data );
}

# ============================================================
sub _is_uuid {
# ============================================================
	my $value = shift;
	return 0 if ref $value;
	return $value =~ /^[0-9A-Fa-f]{8}\-[0-9A-Fa-f]{4}\-[0-9A-Fa-f]{4}\-[0-9A-Fa-f]{4}\-[0-9A-Fa-f]{12}$/;
}

1;
