package Shinsa::Schema::Result::Cohort;

use warnings;
use strict;

use Moose;
use base qw( DBIx::Class );

has uuid         => ( is => 'rw' );
has exam         => ( is => 'rw' );
has panel        => ( is => 'rw' );
has area         => ( is => 'rw' );
has name         => ( is => 'rw' );
has description  => ( is => 'rw' );
has parent       => ( is => 'rw' );
has info         => ( is => 'rw' );

__PACKAGE__->load_components( qw( UUIDColumns InflateColumn::Serializer Core ));
__PACKAGE__->table( 'cohort' );
__PACKAGE__->add_columns(
	uuid         => { data_type => 'string' },
	exam         => { data_type => 'string' },
	panel        => { data_type => 'string' },
	area         => { data_type => 'string' },
	name         => { data_type => 'string' },
	description  => { data_type => 'string' },
	parent       => { data_type => 'string' },
	info         => { data_type => 'string', serializer_class => 'JSON', serializer_options => { allow_blessed => 1, convert_blessed => 1, pretty => 0 }}
);
__PACKAGE__->uuid_columns( 'uuid' );
__PACKAGE__->set_primary_key( 'uuid' );

__PACKAGE__->belongs_to( 'exam'      => 'Shinsa::Schema::Result::Examination' );
__PACKAGE__->belongs_to( 'panel'     => 'Shinsa::Schema::Result::Panel' );
__PACKAGE__->belongs_to( 'parent'    => 'Shinsa::Schema::Result::Cohort' );
__PACKAGE__->has_many(   'children'  => 'Shinsa::Schema::Result::Cohort',   'parent' );
__PACKAGE__->has_many(   'examinees' => 'Shinsa::Schema::Result::Examinee', 'examiner' );

1;
