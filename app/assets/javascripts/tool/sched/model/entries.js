
/*global _ sched Backbone */

sched.ns( 'model' );

sched.model.Entries = Backbone.Collection.extend({

    /**
     * @param Backbone.Model
     */
    model: sched.model.Entry,

    /**
     * Initialise the collection
     *
     */
    initialize: function( models, options ) {

        _.extend( this, options );

    },

    /**
     * Return the current URL for the entries data
     *
     */
    url: function() {

        return '/calendars/entries.json?' +
            'start_date=' +this.startDate.format( sched.cal.DATE_FORMAT ) +
            '&end_date=' +this.endDate.format( sched.cal.DATE_FORMAT ) +
            (this.projectId ? '&project_id=' +this.projectId : '');

    }

});

