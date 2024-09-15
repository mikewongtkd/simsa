package Simsa::User;
use base qw( Simsa::DBO );
use Simsa::Role;
use Data::Dumper;

# ============================================================
sub grant_root_access {
# ============================================================
	my $self = shift;
	$self->{ data }{ root } = 1;
}

# ============================================================
sub role {
# ============================================================
	my $self   = shift;
	my $where  = shift;
	my $filter = shift;
	my $exam   = undef;

	if( $where eq 'where' && exists $filter->{ exam }) {
		$exam = $filter->{ exam };
		return ($self->roles( $exam ))[ 0 ];

	} else {
		return 'Public';
	}
}

# ============================================================
sub roles {
# ============================================================
	my $self   = shift;
	my $where  = shift;
	my $filter = shift;
	my $exam   = undef;

	if( $where eq 'where' && exists $filter->{ exam }) {
		$exam = $filter->{ exam };
		$exam = Simsa::DBO::_get( $exam );

	} else {
		return (qw( Public ));
	}

	my $sql = 'select class, json_extract( document.data, "$.user" ) as user, json_extract( document.data, "$.exam" ) as exam from document where user = ? and exam = ?';
	my $sth = Simsa::DBO::_prepare_statement( 'roles', $sql );

	$sth->execute( $self->uuid(), $exam->uuid());

	my $order = $Simsa::Role::order;
	my @roles = ();
	push @roles, 'Root' if exists $self->{ data }{ root } && $self->{ data }{ root };
	while( my $document = $sth->fetchrow_hashref()) {
		next unless $document->{ class } =~ /^role/i;
		my $role = $document->{ class };
		$role =~ s/^Role:://;
		die "Invalid role $!" unless exists $order->{ $role };
		push @roles, $role;
	}

	@roles = sort { $order->{ $a } <=> $order->{ $b } } @roles;
	@roles = ( 'Public' ) unless @roles;
	return @roles;
}

1;
