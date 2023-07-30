package Shinsa::Config;
use JSON::XS;
use File::Slurp qw( read_file );

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
	my $self = shift;
	my $file = '/usr/local/shinsa/config.json';
	my $text = read_file( $file );
	my $json = new JSON::XS();
	my $data = $json->decode( $text );

	$self->{ config } = $data;
	return $data;
}

# ============================================================
sub host {
# ============================================================
	my $self     = shift;
	my $params   = shift;
	my $protocol = $params->{ protocol } || $self->{ config }{ protocol } || 'http://';
	my $host     = $params->{ host }     || $self->{ config }{ host } || '*';
	my $port     = $params->{ port }     || $self->{ config }{ port } || '';

	my $value    = "$protocol$host";
	$value .= ":$port" if $port;
	return $value;
}
1;
