/*global _ Backbone User */

var Users = Backbone.Collection.extend({

  model: User,

  initialize: function(users){
    var collection = this;
    _.each(users, function(user){
      collection.add(user);
    });
  }

});