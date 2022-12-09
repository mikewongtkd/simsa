package Shinsa::RequestHandler;

# ============================================================
sub new {
# ============================================================
	my ($class) = map { ref || $_ } shift;
	my $self = bless {}, $class;
	$self->init();
	return $self;
}

# ============================================================
sub init {
# ============================================================
	my $self  = shift;
}

# ============================================================
sub subject {
# ============================================================
	my $self    = shift;
	my $class   = ref $self;
	my $subject = $class;

	$subject =~ /^Shinsa//;
	$subject = lc( join( '-', split /::/, $subject ));

	return $subject;
}

1;
