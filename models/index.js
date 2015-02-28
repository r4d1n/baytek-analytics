var Sequelize = require('sequelize');
var fs = require('fs');


var mysqlTables = {};

function generateViews(sequelize, callback){
	//* Read sql_views.sql file
	fs.readFile('./models/sql_views.sql', function (err, data) {
		if (err) throw err;

		var sqlQueries = data.toString().split(";");
		function executeQueries(sqlQueries, index){
			if(sqlQueries.length <= index){
//				console.log('Views Created!');
				return callback();
			}
			if(sqlQueries[index].length == 0){
				return executeQueries(sqlQueries, ++index);
			}
			sequelize.query(sqlQueries[index])
			.success(function(r){
				executeQueries(sqlQueries, ++index);
			}).error(function(err){ throw err;});
		};
		executeQueries(sqlQueries, 0);

	});/**/
};

function generateTables(sequelize, force, cb){

	mysqlTables.sequelize = sequelize;
	
	mysqlTables.Ficheiro = sequelize.define('ficheiros', {
		tag: {type: Sequelize.STRING, unique: 'fileKey'},
		nome: {type: Sequelize.STRING, unique: 'fileKey'},
		file: Sequelize.STRING
	});

	mysqlTables.Play = sequelize.define('play_table', {
		startedAt: {type: Sequelize.DATE},

	});

	
	
	// mySQL VIEWs
	/////////////

	/////////////
	
	sequelize.sync({force: force})
	.success(function(){
		if(force)
			generateViews(sequelize, cb);
		else
		 	cb();
	})
	.error(function(error){
		console.log(error);
	});

	
};

mysqlTables.config = function (cb){

	if(!(process.env.CLEARDB_DATABASE_URL))
		throw 'Invalid database configuration';
		
	var forcesync = process.env.DB_FORCE_SYNC ? true : false;
		
		
	var loginString = process.env.CLEARDB_DATABASE_URL;
		loginString = (loginString.indexOf("?") !== -1 ? loginString.slice(0, loginString.indexOf("?")) : loginString);
		
	var sequelizeObj = process.env.LOGDB ? {dialect: 'mysql'} : {dialect: 'mysql', logging: false};
	var sequelize = new Sequelize(loginString, sequelizeObj);
	generateTables(sequelize, forcesync, cb);
	
	return mysqlTables;	
};


//public Database
module.exports = mysqlTables;