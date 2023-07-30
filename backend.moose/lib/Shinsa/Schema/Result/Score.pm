package Shinsa::Schema::Result::Score;

use warnings;
use strict;

use Moose;
use base qw( DBIx::Class );

has uuid     => ( is => 'rw' );
has given    => ( is => 'rw' );
has examinee => ( is => 'rw' );
has examiner => ( is => 'rw' );
has info     => ( is => 'rw' );

__PACKAGE__->load_components( qw( UUIDColumns InflateColumn::DateTime Core ));
__PACKAGE__->table( 'score' );
__PACKAGE__->add_columns(
	uuid     => { data_type => 'string' },
	given    => { data_type => 'string' },
	examinee => { data_type => 'string' },
	examiner => { data_type => 'string' },
	info     => { data_type => 'string', serializer_class => 'JSON', serializer_options => { allow_blessed => 1, convert_blessed => 1, pretty => 0 }}
);

__PACKAGE__->uuid_columns( 'uuid' );
__PACKAGE__->set_primary_key( 'uuid' );

__PACKAGE__->belongs_to( 'examinee'    => 'Shinsa::Schema::Result::Examinee' );
__PACKAGE__->belongs_to( 'examiner'    => 'Shinsa::Schema::Result::Examiner' );

1;
