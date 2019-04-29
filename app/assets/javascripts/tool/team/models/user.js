/*global _ Backbone */

var User = Backbone.Model.extend({
  
    initialize: function(options){
        _.extend(this, options);
    },

    url: function() {
        return "/team_api/users/" + this.id + ".json";
    }

});