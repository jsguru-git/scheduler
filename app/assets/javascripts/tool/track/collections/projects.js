/*global _ log track Backbone */

track.ns ( 'collection' );

track.collection.Projects = Backbone.Collection.extend({

    model: track.model.Project,

    initialize: function(models, options) {

        _.extend(this, options);
    },

    url: function() {

        return '/track_api/projects.json?' +
        'user_id=' + this.user_id;
    }
});
