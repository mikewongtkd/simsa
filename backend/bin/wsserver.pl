#! /usr/bin/perl

use lib qw( lib /usr/local/shinsa/lib );
use Clone qw( clone );
use Data::Structure::Util qw( unbless );
use Mojolicious::Lite;
use JSON::XS;
use Digest::SHA1 qw( sha1_hex );
use FreeScore::Config;
use Try::Tiny;
use List::MoreUtils qw( first_index );
use Data::Dumper;

srand();

our $json   = new JSON::XS();
our $config = new FreeScore::Config();

# ============================================================
websocket '/grassroots/:tournament/:ring' => sub {
# ============================================================
	my $self       = shift;
	my $tournament = $self->param( 'tournament' );
	my $ring       = $self->param( 'ring'       );
	my $manager    = new FreeScore::Forms::GrassRoots::RequestManager( $tournament, $ring, $self->tx() );
	my $progress   = undef;
	my $staging    = undef;
	my $id         = sprintf "%s", sha1_hex( $self->tx() );
	my $group      = $ring eq 'staging' ? "$tournament-staging" : sprintf "%s-ring-%d", $tournament, $ring;

	$self->inactivity_timeout( 3600 ); # 1 hour

	# ===== REGISTER THE CLIENT GROUP
	my $c = $client->{ $group }{ $id } = { id => $id, device => $self->tx() }; 

	# ----------------------------------------
	# Handle messages
	# ----------------------------------------
	$self->on( message => sub {
		my $self    = shift;
		my $request = $json->decode( shift );

		$request->{ tournament } = $tournament;
		$request->{ ring }       = $ring;

		# ===== READ PROGRESS
		try   { 
			$progress = new FreeScore::Forms::GrassRoots( $tournament, $ring ); 
		} catch { $c->{ device }->send( { json => { error => "Error reading database '$tournament', ring $ring: $_" }}); };

		# ===== HANDLE REQUEST
		my $clients = $client->{ $group };
		try   { $manager->handle( $request, $progress, $clients ); }
		catch { $c->{ device }->send( { json => { error => "Error while processing request: $_\n", request => $request }}); };
	});
};

# ============================================================
# HYPNOTOAD SERVER
# ============================================================
mkdir '/var/log/freescore' unless -e '/var/log/freescore';
app->config( hypnotoad => { listen => [ 'http://*:3080' ], pid_file => '/var/run/grassroots.pid' });
app->log( new Mojo::Log( path => '/var/log/freescore/grassroots.log', level => 'error' ));
app->start();
