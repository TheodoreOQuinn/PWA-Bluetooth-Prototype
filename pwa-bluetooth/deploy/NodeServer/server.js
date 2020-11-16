// Simple web server and websocket server
// (c) 2018, Reto Bättig
//
// The web server serves static files from the directory "./public"
var express = require('express');
var app = express();
const normalizePort = require('normalize-port');

// Static Web Server
app.use(express.static('public'));
// Start Web Server
var port = normalizePort(process.env.PORT || '3000');
app.listen(port, function () {
    console.log('Web Server listening on port '+port);
});
