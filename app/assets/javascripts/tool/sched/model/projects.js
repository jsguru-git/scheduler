
/*global sched Backbone */

sched.ns( 'model' );

sched.model.Projects = Backbone.Collection.extend({

    model: sched.model.Project,

    url: '/calendars/projects.json'

});

