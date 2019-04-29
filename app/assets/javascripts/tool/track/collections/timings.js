/*global _ log track Backbone moment */

track.ns ( 'collection' );

track.collection.Timings = Backbone.Collection.extend({

    model: track.model.Timing,

    initialize: function(models, options) {

        _.extend(this, options);
        // Save models when they get added to a collection
        var collection = this;
        this.bind('add', function(model) {
            if(model.isNew()){
                model.save({}, {
                    error: function(model, err) {
                        // Rollback the collection on failure.
                        // Can be removed in Backbone v0.9.9 with use of merge
                        model.showErrors(err.responseText);
                        collection.remove(model);
                        $('.submit-loader').hide();
                    }
                });
            }
        });

        // Update timer on callbacks
        this.on('all', function() {
            if(window.Track.timer == undefined) {
                window.Track.timer = new track.model.Timer();
            }
        });

        this.on('sync', function() {
            if(window.Track.timer.get('featureStatus') == true) {
                window.Track.timer.reset();
            }
        });

        this.on('remove', function() {
            if(window.Track.timer.get('featureStatus') == true) {
                window.Track.timer.reset();
            }
        });
    },

    url: function() {

        return '/track_api/timings.json?' +
        'user_id='     + this.user_id +
        '&start_date=' + this.start_date +
        '&end_date='   + this.end_date;
    },

    trackedMinutes: function(date) {
        var time = 0;
        this.each(function(timing){

            if(timing.get('task') != undefined && timing.get('task')['count_towards_time_worked'] == true && moment(timing.get('started_at')).format('YYYY-MM-DD') == date) {
                time = time + timing.get('duration_minutes');
            }

        });

        return time;
    }
});
