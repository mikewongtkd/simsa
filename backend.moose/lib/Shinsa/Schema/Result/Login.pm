package Shinsa::Schema::Result::Login;

use warnings;
use strict;

use Moose;
use base qw( DBIx::Class::Core );

has uuid   => ( is => 'rw' );
has email  => ( is => 'rw' );
has pwhash => ( is => 'rw' );
has info   => ( is => 'rw' );

__PACKAGE__->load_components( qw( UUIDColumns InflateColumn::Serializer Core ));
__PACKAGE__->table( 'login' );
__PACKAGE__->add_columns(
	uuid   => { data_type => 'string' },
	email  => { data_type => 'string' },
	pwhash => { data_type => 'string', is_nullable => 1 },
	info   => { data_type => 'string', serializer_class => 'JSON', serializer_options => { allow_blessed => 1, convert_blessed => 1, pretty => 0 }}
);

__PACKAGE__->uuid_columns( 'uuid' );
__PACKAGE__->set_primary_key( 'uuid' );

__PACKAGE__->add_unique_constraint([ 'email' ]);
__PACKAGE__->has_many( 'user' => 'Shinsa::Schema::Result::User', 'uuid' );

1;
