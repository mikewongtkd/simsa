#! /usr/bin/perl

use lib qw( lib /usr/local/shinsa/lib );
use Mojolicious::Lite;
use JSON::XS;
use Shinsa::Config;
use Try::Tiny;
use Data::Dumper;

srand();

our $json    = new JSON::XS();
our $config  = new Shinsa::Config();
our $clients = {};

# ============================================================
websocket '/shinsa/api/v1/:test/:id' => sub {
# ============================================================
	my $self       = shift;
	my $test       = $self->param( 'test' );
	my $id         = $self->param( 'id' );
	my $manager    = new Shinsa::RequestManager( $test );

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
app->config( hypnotoad => { listen => [ $config->host({ port => 3080 }) ], pid_file => '/var/run/shinsa.pid' });
app->log( new Mojo::Log( path => '/var/log/shinsa/wsserver.log', level => 'error' ));
app->start();
