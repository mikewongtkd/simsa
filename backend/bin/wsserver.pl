#! /usr/bin/perl

use lib qw( lib /usr/local/shinsa/lib );
use Clone qw( clone );
use Data::Structure::Util qw( unbless );
use Mojolicious::Lite;
use JSON::XS;
use Digest::SHA1 qw( sha1_hex );
use Shinsa::Config;
use Try::Tiny;
use List::MoreUtils qw( first_index );
use Data::Dumper;

srand();

our $json    = new JSON::XS();
our $config  = new Shinsa::Config();
our $clients = {};

# ============================================================
websocket '/shinsa/api/v1/:id' => sub {
# ============================================================
	my $self       = shift;
	my $id         = $self->param( 'id' );
	my $manager    = new Shinsa::RequestManager( $id );

	$self->inactivity_timeout( 3600 ); # 1 hour

	# ===== REGISTER THE CLIENT GROUP
	my $client = $clients->{ $id } = { id => $id, device => $self->tx() }; 

	# ----------------------------------------
	# Handle messages
	# ----------------------------------------
	$self->on( message => sub {
		my $self    = shift;
		my $request = $json->decode( shift );

		# ===== HANDLE REQUEST
		try   { $manager->handle( $id, $request, $clients ); }
		catch { $client->{ device }->send( { json => { error => "Error while processing request: $_\n", request => $request }}); };
	});
};

# ============================================================
# HYPNOTOAD SERVER
# ============================================================
mkdir '/var/log/shinsa' unless -e '/var/log/shinsa';
app->config( hypnotoad => { listen => [ 'http://*:3080' ], pid_file => '/var/run/shinsa.pid' });
app->log( new Mojo::Log( path => '/var/log/shinsa/wsserver.log', level => 'error' ));
app->start();
