import { WebSocketServer } from 'ws';

const sqlite = require( 'sqlite-sync' );
const wss    = new WebSocketServer({ port : 8055 });

wss.on( 'connection', ws => {
	ws.on( 'message', message => {
		sqlite.connect( 'shinsa.sqlite' );
	});
});
