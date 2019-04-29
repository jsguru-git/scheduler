
/*global sched Backbone */

sched.ns( 'model' );

sched.model.Project = Backbone.Model.extend({

    url: function() {
        return '/track_api/projects/' + this.get('id') + '.json';
    }

});

