/*global _ track Backbone */

track.ns( 'model' );

track.collection.Users = Backbone.Collection.extend({

    model: track.model.User,

    initialize: function( models, options ) {

        _.extend( this, options );
    },

    url: function() {

        return '/calendars/users.json';
    }

});
