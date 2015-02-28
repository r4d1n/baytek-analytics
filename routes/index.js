var express = require('express');
var router = express.Router();

var loginTemplates = require('./bb')('/login');
var mainTemplates = require('./bb')('/main');

var Auth = require('./auth'),
    Users = require('./users');





  // =====================================
  // =========     HOME PAGE      ========
  // =====================================
  router.get('/', Auth.isLoggedIn, function(req, res, next){
    res.render('main/index.jade', {templates: mainTemplates, user: req.session.userName});
  });

  // =====================================
  // LOGIN ===============================
  // =====================================
  // show the login form
  router.get('/login', function(req, res, next){
    res.render('login/index.jade', {templates: loginTemplates});
  });

  // process the signup form
  //app.post('/api/signup', );

  // process the login form
  //app.post('/api/login', Auth.login);



  // process the signup form
  // app.post('/signup', do all our passport stuff here);

  // =====================================
  // LOGOUT ==============================
  // =====================================
  //app.get('/logout', Auth.logout);


  //====================================== MAIN ROUTES ======================================//



  /*==========================================================================================//
  //==================================== API for Backbone ====================================//
  //======================================= USERS ============================================//
  app.get('/api/users/', 			 Auth.hasAccess, Users.getAll);
  app.get('/api/users/:userName',  Auth.hasAccess, Users.getOne);
  app.post('/api/users/', 		 Auth.hasAccess, Auth.signup);
  app.post('/api/users/:userName',  Auth.hasAccess, Users.editOne);
  // //==========================================================================================//
  // //======================================= MESSAGES =========================================//
  app.get('/api/messages/', 		 Auth.hasAccess, Messages.getAll);
  // app.get('/api/messages/:id', 	 routes.auth.hasAccess, routes.Messages.getOne);
  app.post('/api/messages/', 		 Auth.hasAccess, Messages.newOne);
  // app.put('/api/messages/:id', 	 routes.auth.hasAccess, routes.Messages.editOne);
  // //==========================================================================================//
  // //======================================== PERFORMANCE =====================================//
  app.post('/api/performance/setup',	Auth.hasAccess, Performance.setup);
  app.put('/api/performance/teardown', Auth.hasAccess, Performance.teardown);
  // //==========================================================================================//
  // //======================================== MEMORY ==========================================//
  // app.post('/api/memory/start', 		 routes.auth.hasAccess, routes.Memory.start);
  // app.post('/api/memory/stop', 		 routes.auth.hasAccess, routes.Memory.stop);
  // app.get('/api/memory/',		 		 routes.auth.hasAccess, routes.Memory.getAll);
  // app.delete('/api/memory/', 			 routes.auth.hasAccess, routes.Memory.destroyAll);
  //==========================================================================================*/


module.exports = router;




