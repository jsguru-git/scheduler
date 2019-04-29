/*global _ Backbone */

user.ns( 'model' );

user.model.User = Backbone.Model.extend({
  
    initialize: function(options){
        _.extend(this, options);
    },

    url: function() {
        return "/team_api/users/" + this.id + ".json";
    }

});