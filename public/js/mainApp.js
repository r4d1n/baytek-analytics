(function($){

  appConfig = {
    baseURL: '/api/'
  };

  // Backbone
  var BB = {
    User: {
      Login: {},
      Register: {}
    },
    Notification: {},
    Active: {
      User: {}
    }
  };

  // USER
  (function(){
    BB.User.Model = Backbone.Model.extend({
      url: function(){
        if(_.isUndefined(this.id) ){
          if(this._register && delete this._register) return appConfig.baseURL + 'users';
          return appConfig.baseURL + 'login';
        }else{
          return appConfig.baseURL + 'user/' + encodeURIComponent(this.id);
        }
      },
      validate: function (attrs, options) {
        this.bootstrapValidator.validate();

        if(!this.bootstrapValidator.isValid()) return 'Invalid model';

        return;
      }
    });
    BB.User.Login.View = Backbone.View.extend({
      bindings: {
        '#login-username': 'userName',
        '#login-password': 'password'
      },
      events: {
        'click #login-btn': 'login',
        'click #login-showRegister': 'showRegisterView',
        'keypress #validate': 'keypress'
      },
      validation: {
        feedbackIcons: {
          valid: 'glyphicon glyphicon-ok',
          invalid: 'glyphicon glyphicon-remove',
          validating: 'glyphicon glyphicon-refresh'
        },
        fields: {
          username: {
            validators: {
              notEmpty: {
                message: '*Username required'
              }
            }
          },
          password: {
            validators: {
              notEmpty: {
                message: '*Password is required'
              }
            }
          }
        }
      },
      initialize: function () {
        this.model.on('sync', this.success, this);
        this.model.on('error', this.error, this);
        this.model.on('invalid', this.invalid, this);
      },
      login: function () {
        this.model.save();
      },
      render: function () {
        this.$el.html($.tpl['loginForm']({}));

        // Notification Box
        this.notification = new BB.Notification.View({
          model: new BB.Notification.Model(),
          el: '#notification-wrapper'
        });
        this.notification.model.set('text', '');

        // Validation Rules
        this.$el.find('#validate').bootstrapValidator(this.validation);
        this.model.bootstrapValidator = this.$el.find('#validate').data('bootstrapValidator');


        this.stickit();

        return this;
      },
      showRegisterView: function () {
        window.location.hash = '#register';
      },
      keypress: function (e) {
        var key = e.which;
        if(key == 13){ this.$el.find('button#login-btn').trigger('click');}
      },
      success: function (model, resp, options) {
        window.location = '/';
      },
      error: function (model, resp, options) {
        if(resp.status == 404){
          this.notification.model.set('text', 'Service Unavailable. Please try again in a few minutes...');
        }else{
          this.notification.model.set('text', resp.responseText);
          console.log(resp);
        }
      },
      invalid: function (args) {
        return;
      }
    });
    BB.User.Register.View = Backbone.View.extend({
      bindings: {
        '#input-username-register': 'userName',
        '#input-password-register': 'password'
      },
      events: {
        'click #register-btn': 'register',
        'click #register-showLogin': 'showLoginView',
        'keypress #validate': 'keypress'
      },
      validation: {
        feedbackIcons: {
          valid: 'glyphicon glyphicon-ok',
          invalid: 'glyphicon glyphicon-remove',
          validating: 'glyphicon glyphicon-refresh'
        },
        fields: {
          username: {
            validators: {
              notEmpty: {
                message: '*Username required'
              },
              restrictedNames: {
                message: '*Username restricted'
              },
              stringLength: {
                min: 3,
                message: '*Username must have more than 3 characters'
              }

            }
          },
          password: {
            validators: {
              notEmpty: {
                message: '*Password is required'
              },
              identical: {
                field: 'password2',
                message: '*Passwords must match'
              },
              stringLength: {
                min: 4,
                message: '*Password must have more than 4 characters'
              }
            }
          },
          password2: {
            validators: {
              notEmpty: {
                message: '*Confirm password'
              },
              identical: {
                field: 'password'
              }
            }
          }
        }

      },
      initialize: function () {
        this.model.on('sync', this.success, this);
        this.model.on('error', this.error, this);
        this.model.on('invalid', this.invalid, this);
      },
      register: function () {
        this.model._register = true;
        this.model.save();
      },
      render: function () {
        this.$el.html($.tpl['register-view']({}));

        // Notification Box
        this.notification = new BB.Notification.View({
          model: new BB.Notification.Model(),
          el: '#notification-wrapper'
        });

        // Validation Rules
        this.$el.bootstrapValidator(this.validation);
        this.model.bootstrapValidator = this.$el.data('bootstrapValidator');

        this.stickit();

        return this;
      },
      keypress: function (e) {
        var key = e.which;
        if(key == 13){ this.$el.find('button#register-btn').trigger('click');}
      },
      showLoginView: function () {
        window.location.hash = '#login';
      },
      success: function (model, resp, options) {
        window.location = '/';
      },
      error: function (model, resp, options) {
        if(resp.status == 404){
          this.notification.model.set('text', 'Service Unavailable. Please try again in a few minutes...');
        }else{
          this.notification.model.set('text', resp.responseText);
          console.log(resp);
        }
      },
      invalid: function (args) {
        return;
      }
    });
  })();


  // NOTIFICATIONS
  (function(){
    BB.Notification.Model = Backbone.Model.extend({
      defaults:{
        text: '',
        type: 'alert-danger',
        time: 13000
      }
    });
    BB.Notification.View = Backbone.View.extend({
      bindings: {
        '#notification-text': {
          observe: 'text',
          onGet: 'showNotification'
        }
      },
      showNotification: function(val){
        var self = this;
        if(val===''){
          this.$el.hide();
        }else{
          this.$el.show();
          setTimeout(function(){
            self.model.set('text', '');
          }, this.model.get('time'));
        }

        return val;
      },

      initialize: function(){
        var self = this;
        this.$el.html('<div style="display: none" class="alert ' + self.model.get('type') + '" id="notification-text"></div>');

        //Binding
        this.stickit();

        return this;
      }

    });
  })();

  // INIT VIEW STATUS WIDGET
  (function() {
    BB.Status.Model = Backbone.Model.extend({


    });
    BB.Status.View = Backbone.View.extend({
      initialize: function(){
        var self = this;
        // this.$el.html();

        //Binding
        this.stickit();

        return this;
      }
    });
  })()

  // Workspace
  var Workspace = Backbone.Router.extend({
    routes:{
      '': 'loginController',
      'login': 'loginController',
      'register': 'registerController',
      '*path': 'loginController'
    },
    loginController: function () {
      BB.Active.User.Model = BB.Active.User.Model || new BB.User.Model();
      BB.Active.User.Login = BB.Active.User.Login || new BB.User.Login.View({el: '#content-wrapper #login', model: BB.Active.User.Model});
      BB.Active.User.Login.render();
    },
    registerController: function () {
      BB.Active.User.Model = BB.Active.User.Model || new BB.User.Model();

      BB.Active.User.Register = BB.Active.User.Register || new BB.User.Register.View({el: '#content-wrapper #login', model: BB.Active.User.Model});
      BB.Active.User.Register.render();
    }
  });


  $(document).ready(function(){
    new Workspace();
    Backbone.history.start();
  });


)(jQuery);
