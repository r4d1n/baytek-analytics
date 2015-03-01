(function($){

	// Custom Validator
	/*$.fn.bootstrapValidator.validators.restrictedNames = {
	restrictedNames: ['about', 'access', 'account', 'accounts', 'add', 'address', 'adm', 'admin', 'administration', 'adult',
	'advertising', 'affiliate', 'affiliates', 'ajax', 'analytics', 'android', 'anon', 'anonymous', 'api', 'app', 'apps', 'archive', 'atom', 'auth', 'authentication', 'avatar','backup', 'banner', 'banners', 'bin', 'billing', 'blog', 'blogs', 'board', 'bot',
	'bots', 'business','chat', 'cache', 'cadastro', 'calendar', 'campaign', 'careers', 'cgi', 'client', 'cliente', 'code', 'comercial',
	'compare', 'config', 'connect', 'contact', 'contest', 'create', 'code', 'compras', 'css','dashboard', 'data', 'db', 'design', 'delete', 'demo', 'design', 'designer', 'dev', 'devel', 'dir',
	'directory', 'doc', 'docs', 'domain', 'download', 'downloads','edit', 'editor', 'email', 'ecommerce','forum', 'forums', 'faq', 'favorite', 'feed', 'feedback', 'flog', 'follow', 'file', 'files', 'free', 'ftp','gadget', 'gadgets', 'games', 'guest', 'group', 'groups','help', 'home', 'homepage', 'host', 'hosting', 'hostname', 'html', 'http', 'httpd', 'https', 'hpg','info', 'information', 'image', 'img', 'images', 'imap', 'index', 'invite', 'intranet', 'indice',
	'ipad', 'iphone', 'irc','java', 'javascript', 'job', 'jobs', 'js','knowledgebase','log', 'login', 'logs', 'logout', 'list', 'lists','mail', 'mail1', 'mail2', 'mail3', 'mail4', 'mail5', 'mailer', 'mailing', 'mx', 'manager', 'marketing',
	'master', 'me', 'media', 'message', 'microblog', 'microblogs', 'mine', 'mp3', 'msg', 'msn', 'mysql',
	'messenger', 'mob', 'mobile', 'movie', 'movies', 'music', 'musicas', 'my','name', 'named', 'net', 'network', 'new', 'news', 'newsletter', 'nick', 'nickname', 'notes', 'noticias',
	'ns', 'ns1', 'ns2', 'ns3', 'ns4','old', 'online', 'operator', 'order', 'orders','page', 'pager', 'pages', 'panel', 'password', 'perl', 'pic', 'pics', 'photo', 'photos', 'photoalbum',
	'php', 'plugin', 'plugins', 'pop', 'pop3', 'post', 'postmaster',
	'postfix', 'posts', 'profile', 'project', 'projects', 'promo', 'pub', 'public', 'python',
	'random', 'register', 'registration', 'root', 'ruby', 'rss','sale', 'sales', 'sample', 'samples', 'script', 'scripts', 'secure', 'send', 'service', 'shop',
	'sql', 'signup', 'signin', 'search', 'security', 'settings', 'setting', 'setup', 'site',
	'sites', 'sitemap', 'smtp', 'soporte', 'ssh', 'stage', 'staging', 'start', 'subscribe',
	'subdomain', 'suporte', 'support', 'stat', 'static', 'stats', 'status', 'store', 'stores', 'system','tablet', 'tablets', 'tech', 'telnet', 'test', 'test1', 'test2', 'test3', 'teste', 'tests', 'theme',
	'themes', 'tmp', 'todo', 'task', 'tasks', 'tools', 'tv', 'talk','update', 'upload', 'url', 'user', 'username', 'usuario', 'usage', 'vendas', 'video', 'videos', 'visitor', 'win', 'ww', 'www', 'www1', 'www2', 'www3', 'www4', 'www5', 'www6', 'www7', 'wwww', 'wws', 'wwws', 'web', 'webmail', 'website', 'websites', 'webmaster', 'workshop', 'xxx', 'xpg', 'you', 'yourname', 'yourusername', 'yoursite', 'yourdomain'],
	/**
	* @param {BootstrapValidator} validator The validator plugin instance
	* @param {jQuery} $field The jQuery object represents the field element
	* @param {Object} options The validator options
	* @returns {Boolean}
	*
	validate: function(validator, $field, options) {
	// You can get the field value
	var value = $field.val();

	if(this.restrictedNames.indexOf(value) < 0)
	return true;

	return false;

}
};*/


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


})(jQuery);
