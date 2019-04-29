/*global Backbone JST */
var Phase = Backbone.Model.extend({

  url: function() {
    if(this.get('id')) { 
      return '/phases/' + this.get('id') + '.json';
    }else{
      return '/phases.json';
    }
  }

});