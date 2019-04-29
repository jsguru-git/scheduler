// Schedule entries

/*global _ log track Backbone */

/**
 * There are entries in the schedule that will be imported when
 * 'reset via schedule' is called for a day.
 * Entries come from the following url =>
 * http://ruby.localhost.com:3000/schedule/entries
 */

track.ns ( 'collection' );

track.collection.Entries = Backbone.Collection.extend({

    model: track.model.Entry,

    initialize: function(models, options) {

        _.extend(this, options);
    },

    url: function() {

        return '/calendars/entries/entries_for_user.json?' +
        'user_id='     + this.user_id +
        '&start_date=' + this.start_date +
        '&end_date='   + this.end_date;
    }
});
