package Shinsa::Schema::Result::Panel;

use warnings;
use strict;

use Moose;
use base qw( InflateColumn::Serializer DBIx::Class::Core );

has uuid   => ( is => 'rw' );
has exam   => ( is => 'rw' );
has name   => ( is => 'rw' );
has info   => ( is => 'rw' );

__PACKAGE__->table( 'panel' );
__PACKAGE__->add_columns(
	uuid   => { data_type => 'string' },
	exam   => { data_type => 'string' },
	name   => { data_type => 'string' },
	info   => { data_type => 'string', serializer_class => 'JSON', serializer_options => { allow_blessed => 1, convert_blessed => 1, pretty => 0 }}
);
__PACKAGE__->belongs_to(   'examination'    => 'Shinsa::Schema::Result::Examination',   'exam' );
__PACKAGE__->has_many(     'cohort'         => 'Shinsa::Schema::Result::Cohort',        'panel' );
__PACKAGE__->has_many(     'panelexaminers' => 'Shinsa::Schema::Result::PanelExaminer', 'panel' );
__PACKAGE__->many_to_many( 'examiners'      => 'panelexaminers'                         'examiner' );
__PACKAGE__->uuid_columns( 'uuid' );
__PACKAGE__->set_primary_key( 'uuid' );

1;
