/*global sched _ Backbone */

sched.ns( 'collection' );

sched.collection.RecentProjects = Backbone.Collection.extend({

    model: sched.model.Project,

    initialize: function(options) {

        _.extend(this, options);
    },

    url: function() {

        return '/calendars/projects/recent.json?' +
        'user_id=' + this.user_id;
    }

});

