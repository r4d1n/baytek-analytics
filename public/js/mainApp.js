(function($){

  appConfig = {
    baseURL: '/api/'
  };

  // Backbone
  var BB = {
    Status: {},
    Active: {
      Status: {}
    }
  };

  // INIT VIEW STATUS WIDGET
  (function() {
    BB.Status.Model = Backbone.Model.extend({
      url: function(){
        return appConfig.baseURL + 'status'
      }

    });

    BB.Status.View = Backbone.View.extend({
      bindings: {
        '#runningMachines': 'runningMachines',
        '#totalMachines': 'totalMachines',
        '#totalStock': 'totalStock',
        '#possibleStock': 'possibleStock',
        '#pendingTasks': 'pendingTasks',
        '#money': 'money'
      },

      initialize: function () {
        this.model.on('sync', this.success, this);
        this.model.on('error', this.error, this);
        this.model.on('invalid', this.invalid, this);
      },
      success: function(){},
      error: function(){},
      success: function(){},
      render: function(){
        var self = this;

        this.$el.html($.tpl['status-widgets']());

        //Binding
        this.stickit();

        return this;
      }
    });



  })();

  // Workspace
  var Workspace = Backbone.Router.extend({
    routes:{
      '': 'homePage',
      'login': 'loginController',
      'register': 'registerController',
      '*path': 'loginController'
    },

    homePage: function(){
      BB.Active.Status.Model = BB.Active.Status.Model || new BB.Status.Model();
      BB.Active.Status.View = BB.Active.Status.View || new BB.Status.View({el: '#content-wrapper', model: BB.Active.Status.Model});
      BB.Active.Status.View.render();
    },

  });


  $(document).ready(function(){

    new Workspace();
    Backbone.history.start();

  });


})(jQuery);
