package Shinsa::Schema::Result::User;

use warnings;
use strict;

use Moose;
use base qw( DBIx::Class );

has uuid   => ( is => 'rw' );
has id     => ( is => 'rw' );
has fname  => ( is => 'rw' );
has lname  => ( is => 'rw' );
has email  => ( is => 'rw' );
has dob    => ( is => 'rw' );
has gender => ( is => 'rw' );
has rank   => ( is => 'rw' );
has noc    => ( is => 'rw' );
has info   => ( is => 'rw' );

__PACKAGE__->load_components( qw( UUIDColumns InflateColumn::DateTime Core ));
__PACKAGE__->table( 'user' );
__PACKAGE__->add_columns(
	uuid   => { data_type => 'string' },
	id     => { data_type => 'string' },
	fname  => { data_type => 'string' },
	lname  => { data_type => 'string' },
	email  => { data_type => 'string' },
	dob    => { data_type => 'date' },
	gender => { data_type => 'string' },
	rank   => { data_type => 'string', is_nullable => 1 },
	noc    => { data_type => 'string' },
	info   => { data_type => 'string', serializer_class => 'JSON', serializer_options => { allow_blessed => 1, convert_blessed => 1, pretty => 0 }}
);

__PACKAGE__->uuid_columns( 'uuid' );
__PACKAGE__->set_primary_key( 'uuid' );

__PACKAGE__->belongs_to( 'login'       => 'Shinsa::Schema::Result::Login', 'email' );
__PACKAGE__->belongs_to( 'examination' => 'Shinsa::Schema::Result::Examination' );
__PACKAGE__->belongs_to( 'examinee'    => 'Shinsa::Schema::Result::Examinee' );
__PACKAGE__->belongs_to( 'examiner'    => 'Shinsa::Schema::Result::Examiner' );
__PACKAGE__->belongs_to( 'official'    => 'Shinsa::Schema::Result::Official' );

1;
