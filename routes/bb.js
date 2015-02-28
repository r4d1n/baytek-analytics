var fs = require('fs');
var jade = require('jade');

// Array Remove - By John Resig (MIT Licensed)
Array.prototype.remove = function(from, to) {
  var rest = this.slice((to || from) + 1 || this.length);
  this.length = from < 0 ? this.length + from : from;
  return this.push.apply(this, rest);
};


module.exports = function(folder){
	// Get views in file './views' except index.jade
	var appTemplates = fs.readdirSync('./views'+ folder);
	appTemplates.remove(appTemplates.indexOf('index.jade'));
	appTemplates.remove(appTemplates.indexOf('layout.jade'));

	var htmlOutput = '';
	for(var i in appTemplates){
		if(typeof appTemplates[i] !== 'function')
		htmlOutput += jade.renderFile('./views'+folder+'/'+appTemplates[i], {});
	}

	return htmlOutput;
}