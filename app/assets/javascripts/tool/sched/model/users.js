
/*global _ sched Backbone */

sched.ns( 'model' );

sched.model.Users = Backbone.Collection.extend({

    model: sched.model.User,

    initialize: function( models, options ) {

        _.extend( this, options );

    },

    /**
     * Return URL for loading users, filtering optionally by project and/or team
     *
     * @return String
     */
    url: function() {

        return '/calendars/users.json?'
            + (this.projectId && this.showType != 'all' ? '&project_id=' +this.projectId : '')
            + (this.teamId ? '&team_id=' +this.teamId : '');

    }

});


