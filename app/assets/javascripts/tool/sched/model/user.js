
/*global sched Backbone */

sched.ns( 'model' );

sched.model.User = Backbone.Model.extend({

    url: function() {

        return '/calendars/users/' +this.get('id')+ '.json';
        
    }

});
