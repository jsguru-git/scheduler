// Tasks collection

/*global _ log track Backbone */

track.ns ( 'collection' );

track.collection.Tasks = Backbone.Collection.extend({

    model: track.model.Task,

    initialize: function(options) {

        _.extend(this, options);
    },

    url: function() {

        return '/track_api/projects/' + this.project_id +
               '/tasks.json?' +
               'user_id=' + this.user_id;
    }
});
