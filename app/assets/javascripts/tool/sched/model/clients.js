/*global _ sched Backbone */

sched.ns( 'model' );

sched.model.Clients = Backbone.Collection.extend({

    model: sched.model.Client,

    initialize: function( models, options ) {

        _.extend( this, options );

    },

    /**
     * Return URL for loading users, filtering optionally by project and/or team
     *
     * @return String
     */
    url: function() {

        return '/calendars/clients.json';

    }

});


