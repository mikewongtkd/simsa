package Shinsa::Schema::Result::PanelExaminer;

use warnings;
use strict;

use Moose;
use base qw( DBIx::Class );

has uuid     => ( is => 'rw' );
has panel    => ( is => 'rw' );
has examiner => ( is => 'rw' );
has start    => ( is => 'rw' );
has stop     => ( is => 'rw' );

__PACKAGE__->load_components( qw( InflateColumn::DateTime Core ));
__PACKAGE__->table( 'panel_examiner' );
__PACKAGE__->add_columns(
	uuid     => { data_type => 'string' },
	panel    => { data_type => 'string' },
	examiner => { data_type => 'string' },
	start    => { data_type => 'datetime' },
	stop     => { data_type => 'datetime' }
);
__PACKAGE__->belongs_to(   'panel'          => 'Shinsa::Schema::Result::Panel' );
__PACKAGE__->belongs_to(   'examiner'       => 'Shinsa::Schema::Result::Examiner' );
__PACKAGE__->uuid_columns( 'uuid' );
__PACKAGE__->set_primary_key( 'uuid' );

1;
