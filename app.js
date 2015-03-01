/**
 * Module dependencies.
 */

var debug = require('debug')('baytek-analytics:server');
var http = require('http');

/**
 * Get port from environment and store in Express.
 */

var port = process.env.PORT || '3000';




var express = require('express');
var path = require('path');
var favicon = require('serve-favicon');
var logger = require('morgan');
var cookieParser = require('cookie-parser');
var bodyParser = require('body-parser');
var expressSession = require('express-session');

var routes = require('./routes/index');
var users = require('./routes/users');
var KeenIO = require('keen.io');

var DB = require('./models');

// Define Environment Configuration
var node_env = process.env.NODE_ENV ? process.env.NODE_ENV : 'development';


// NEW RELIC PERFORMANCE METER
if(node_env != 'development'){
    require('newrelic');
}


    // Configure instance. Only projectId and writeKey are required to send data.
    var keen = KeenIO.configure({
        projectId: process.env['KEEN_PROJECT_ID'],
        writeKey: process.env['KEEN_WRITE_KEY']
    });


    // Email Service
    //var postmark = POSTMark(process.env.POSTMARK_API_KEY);
    //////////////////////

    // Login and Synchronize Database
    var dbTables = DB.config(dbSynced);
    /////////////////////////////////

    function dbSynced(){

        var app = express();

        console.log('\u001b[33mMySql Database \u001b[31m' + process.env.CLEARDB_DATABASE_URL + '\u001b[33m synced.\033[0m');

            // all environments
            app.set('db', dbTables);
            app.set('keen', keen);
            // development only

            app.use(expressSession({
                secret: '<h1>YUUUUPPPIIII</h1>',
                maxAge:  new Date() + 7200000,
                key: 'sid',
                cookie: {
                    secret: true,
                    expires: false
                },
                resave: false,
                saveUninitialized: false
            }));

// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'jade');

// uncomment after placing your favicon in /public
//app.use(favicon(__dirname + '/public/favicon.ico'));
app.use(logger('dev'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(cookieParser('sjdhf4;2dhGDas_56f;FDjk'));

app.use('/assets/', express.static(__dirname + '/bower_components'));
app.use(express.static(__dirname + '/public'));

app.use('/', routes);
app.use('/users', users);

// MiddleWare
// Pass DB to request
app.use(function(req,res,next){
    req.db = app.get('db');
    next();
});

// catch 404 and forward to error handler
app.use(function(req, res, next) {
    var err = new Error('Not Found');
    err.status = 404;
    next(err);
});

// error handlers

// development error handler
// will print stacktrace
if (app.get('env') === 'development') {
    app.use(function(err, req, res, next) {
        res.status(err.status || 500);
        res.render('error', {
            message: err.message,
            error: err
        });
    });
}

// production error handler
// no stacktraces leaked to user
app.use(function(err, req, res, next) {
    res.status(err.status || 500);
    res.render('error', {
        message: err.message,
        error: {}
    });
});


module.exports = app;



        app.set('port', port);

        /**
         * Create HTTP server.
         */

        var server = http.createServer(app);

        /**
         * Listen on provided port, on all network interfaces.
         */

        server.listen(port);
        server.on('error', onError);
        server.on('listening', onListening);



        /**
         * Event listener for HTTP server "error" event.
         */

        function onError(error) {
            if (error.syscall !== 'listen') {
                throw error;
            }

            var bind = typeof port === 'string'
                ? 'Pipe ' + port
                : 'Port ' + port;

            // handle specific listen errors with friendly messages
            switch (error.code) {
                case 'EACCES':
                    console.error(bind + ' requires elevated privileges');
                    process.exit(1);
                    break;
                case 'EADDRINUSE':
                    console.error(bind + ' is already in use');
                    process.exit(1);
                    break;
                default:
                    throw error;
            }
        }

        /**
         * Event listener for HTTP server "listening" event.
         */

        function onListening() {
            var addr = server.address();
            var bind = typeof addr === 'string'
                ? 'pipe ' + addr
                : 'port ' + addr.port;
            debug('Listening on ' + bind);
        }




    }
