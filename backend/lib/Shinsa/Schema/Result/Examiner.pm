package Shinsa::Schema::Result::Examiner;

use warnings;
use strict;

use Moose;
use base qw( DBIx::Class );

has uuid   => ( is => 'rw' );
has user   => ( is => 'rw' );
has exam   => ( is => 'rw' );
has info   => ( is => 'rw' );

__PACKAGE__->load_components( qw( InflateColumn::Serializer Core ));
__PACKAGE__->table( 'examiner' );
__PACKAGE__->add_columns(
	uuid   => { data_type => 'string' },
	user   => { data_type => 'string' },
	exam   => { data_type => 'string' },
	info   => { data_type => 'string', serializer_class => 'JSON', serializer_options => { allow_blessed => 1, convert_blessed => 1, pretty => 0 }}
);
__PACKAGE__->belongs_to(   'examination'    => 'Shinsa::Schema::Result::Examination',   'exam' );
__PACKAGE__->has_one(      'user'           => 'Shinsa::Schema::Result::User',          'user' );
__PACKAGE__->has_many(     'scores'         => 'Shinsa::Schema::Result::Score',         'score' );
__PACKAGE__->has_many(     'panelexaminers' => 'Shinsa::Schema::Result::PanelExaminer', 'examiner' );
__PACKAGE__->many_to_many( 'panels'         => 'panelexaminers',                        'panel' );
__PACKAGE__->uuid_columns( 'uuid' );
__PACKAGE__->set_primary_key( 'uuid' );

1;
