package Shinsa::Schema::Result::Examination;

use warnings;
use strict;

use Moose;
use base qw( DBIx::Class );

has uuid        => ( is => 'rw' );
has name        => ( is => 'rw' );
has poster      => ( is => 'rw' );
has address     => ( is => 'rw' );
has start       => ( is => 'rw' );
has schedule    => ( is => 'rw' );
has description => ( is => 'rw' );
has noc         => ( is => 'rw' );
has info        => ( is => 'rw' );

__PACKAGE__->load_components( qw( UUIDColumns InflateColumn::DateTime InflateColumn::Serializer Core ));
__PACKAGE__->table( 'examination' );
__PACKAGE__->add_columns(
	uuid        => { data_type => 'string' },
	name        => { data_type => 'string' },
	poster      => { data_type => 'string' },
	host        => { data_type => 'string' },
	address     => { data_type => 'string' },
	start       => { data_type => 'date',   is_nullable => 1 },
	schedule    => { data_type => 'string', serializer_class => 'JSON', serializer_options => { allow_blessed => 1, convert_blessed => 1, pretty => 0 }},
	description => { data_type => 'string', is_nullable => 1 },
	url         => { data_type => 'string' },
	permissions => { data_type => 'string' },
	info        => { data_type => 'string', serializer_class => 'JSON', serializer_options => { allow_blessed => 1, convert_blessed => 1, pretty => 0 }}

);

__PACKAGE__->uuid_columns( 'uuid' );
__PACKAGE__->set_primary_key( 'uuid' );

__PACKAGE__->has_many(   'examinee' => 'Shinsa::Schema::Result::Examinee', 'exam' );
__PACKAGE__->has_many(   'cohort'   => 'Shinsa::Schema::Result::Cohort',   'exam' );
__PACKAGE__->has_many(   'official' => 'Shinsa::Schema::Result::Official', 'exam' );
__PACKAGE__->has_many(   'examiner' => 'Shinsa::Schema::Result::Examiner', 'exam' );

1;
