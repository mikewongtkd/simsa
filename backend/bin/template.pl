#! /usr/bin/perl

use File::Slurp qw( read_file );

die "No 'db-init.sql' file found $!" unless -e 'db-init.sql';
my $text = read_file( 'db-init.sql' );

while( $text =~ /create table ([\w_]+) \((.*?)\)/gms ) {
	my $table   = $1;
	my $schema  = $2;
	my @columns = split /,\s*/gms, $schema;
	my $columns = [];
	my $foreign = [];

	foreach my $column (@columns) {
		if( $column =~ /^\s*foreign key\(\s*([\w_]+)\s*\) references\s+([\w_]+)\(\s*([\w_]+)\s*\)\s*$/ ) {
			push @$foreign, { name => $1, table => $2, column => $3 };
		} else {
			my ($name, $type, @modifiers) = split /\s+/, $column;
			push @$columns, { name => $name, type => $type, modifiers => join ' ', @modifiers };
		}
	}

	write_template( $table, $columns, $foreign );
}

# ============================================================
sub write_template {
# ============================================================
	my $table   = shift;
	my $columns = shift;
	my $foreign = shift;
	my $name    = [ map { ucfirst $_ } split /_/, $table ];
	my $file    = 'lib/Shinsa/' . join( '/', @$name ) . '.pm';
	my $nosql   = [ grep { $_->{ type } eq 'text_json' } @$columns ];
	my $decode  = '';

	if( @$nosql ) { 
		$decode .= "my \$json = new JSON::XS();\n";
		$decode .= "\$self->{ $_->{ name } } = \$json->decode( \$self->{ $_->{ name } });\n" foreach @$nosql;
	}
	
	if( -e $file ) {

	} else {
		my $package = join( '::', ( 'Shinsa' , @$name ))
		open my $fh, '>', $file or die $!;
		printf $fh "package %s\n\n", $package;
		print $fh <<EOF;
use lib qw( lib );
use Shinsa::DB;
use Moose;

# ============================================================
sub init {
# ============================================================
	my \$self = shift;
	my \$data = shift;

	if( ref \$data eq 'HASH' ) {
		\$self->{ \$_ } = \$data->{ \$_ } foreach (keys \%\$data);

	} elsif( defined \$data && ! ref \$data ) {
		my \$uuid = \$data;
		my \$db   = new Shinsa::DB();
		my \$data = \$db->fetch( \$uuid );
		\$self->{ \$_ } = \$data->{ \$_ } foreach (keys \%\$data);
		$decode
	}
}

# ============================================================
sub factory {
# ============================================================
	my \$data = shift;

	my \$self = new $package( \$data );
	return \$self;
}

EOF
		close $fh;
	}
}
