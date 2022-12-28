package Shinsa::Schema::Result::Examination;

use warnings;
use strict;

use Moose;
use base qw( DBIx::Class::Core );

has uuid        => ( is => 'rw' );
has name        => ( is => 'rw' );
has poster      => ( is => 'rw' );
has address     => ( is => 'rw' );
has start       => ( is => 'rw' );
has schedule    => ( is => 'rw' );
has description => ( is => 'rw' );
has noc         => ( is => 'rw' );
has info        => ( is => 'rw' );

__PACKAGE__->table( 'test' );
__PACKAGE__->add_columns(
	uuid        => { data_type => 'string' },
	name        => { data_type => 'string' },
	poster      => { data_type => 'string' },
	host        => { data_type => 'string' },
	address     => { data_type => 'string' },
	start       => { data_type => 'date',   is_nullable => 1 },
	schedule    => { data_type => 'string' },
	description => { data_type => 'string', is_nullable => 1 },
	url         => { data_type => 'string' },
	permissions => { data_type => 'string' },
	info        => { data_type => 'string' }
);
__PACKAGE__->belongs_to( 'login' => 'Shinsa::Schema::Result::Login', 'email' );
__PACKAGE__->belongs_to( 'examinee' => 'Shinsa::Schema::Result::Examinee', 'uuid' );
__PACKAGE__->belongs_to( 'examiner' => 'Shinsa::Schema::Result::Examiner', 'uuid' );
__PACKAGE__->belongs_to( 'official' => 'Shinsa::Schema::Result::Official', 'uuid' );
__PACKAGE__->uuid_columns( 'uuid' );
__PACKAGE__->set_primary_key( 'uuid' );

1;
