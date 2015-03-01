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
			.success(function(){
				executeQueries(sqlQueries, ++index);
			}).error(function(err){ throw err;});
		}
		executeQueries(sqlQueries, 0);

	});/**/
}

function generateTables(sequelize, force, cb){

	mysqlTables.sequelize = sequelize;

	mysqlTables.User = sequelize.define('user', {
		loginName: {type: Sequelize.STRING},
		realName: {type: Sequelize.STRING},
		email: {type: Sequelize.STRING},
		password: {type: Sequelize.STRING}
	});

    mysqlTables.Arcade = sequelize.define('arcade', {
        gameTitle: {type: Sequelize.STRING},
        physicalId: {type: Sequelize.STRING},
        ticketCapacity: {type: Sequelize.INTEGER},
        coinCapacity: {type: Sequelize.INTEGER},
        firmwareVer: {type: Sequelize.STRING}
    });

    mysqlTables.Player= sequelize.define('player', {
        name: {type: Sequelize.STRING},
        device: {type: Sequelize.STRING}
    });

	mysqlTables.Play = sequelize.define('play', {
		startedAt: {type: Sequelize.DATE},
		finishedAt: {type: Sequelize.DATE},
		gameVersion: {type: Sequelize.STRING},
		coinsIn: {type: Sequelize.INTEGER},
		ticketsOut: {type: Sequelize.INTEGER},
		score: {type: Sequelize.INTEGER}
	});
	mysqlTables.Arcade.hasOne(mysqlTables.Play, {as: 'arcade'});
    mysqlTables.Player.hasOne(mysqlTables.Play, {as: 'player'});

	mysqlTables.Maintenance = sequelize.define('maintenance', {
		action: {type: Sequelize.STRING},
		date: {type: Sequelize.DATE},
		reason: {type: Sequelize.STRING}
	});
	mysqlTables.Arcade.hasOne(mysqlTables.Maintenance, {as: 'arcade'});


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
