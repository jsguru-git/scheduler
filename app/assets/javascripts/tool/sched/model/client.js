
/*global sched Backbone */

sched.ns( 'model' );

sched.model.Client = Backbone.Model.extend({

    url: function() {

        return '/calendars/client/' +this.get('id')+ '.json';
    }

});
