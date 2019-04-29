/*global _ Backbone Phase */
var PhaseCollection = Backbone.Collection.extend({

  model: Phase,

  initialize: function(models, options) {
      _.extend(this, options);
  },

  url: function() {
    return '/phases.json';
  }
});