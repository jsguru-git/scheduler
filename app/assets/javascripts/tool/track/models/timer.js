/*global _ log track Backbone */

track.ns ( 'model' );

track.model.Timer = Backbone.Model.extend({

    initialize: function(options) {
        _.extend(this, options);

        this.set("running", false);
        this.set("featureStatus", false); // Keep track if feature has ever been switched on.
        this.set("date", new Date());

        this.toggleView = new track.view.TimerToggle({
            el: $('#timer-toggle'),
            model: this,
            running: this.get('running')
        });

        this.on('change', function(model) {
            model.toggleView.render(model.get('running'));
        });

        this.interval = null;
        // Don't start by default
        //this.startTimer(this.findStartTime());
    },

    startTimer: function(startAt) {
        this.set('startTime', startAt);
        this.set("running", true);
        this.set("featureStatus", true);
        timer = this;
        this.interval = setInterval(function(){

            var date = new Date();
            var endAt = moment(date).format("YYYY-MM-DDTHH:mm");
            timer.set('endTime', endAt);

            if(endAt > startAt) {
                window.Track.grid.createTimerEntry(startAt, endAt);
            }

        }, 1000);
    },

    endTimer: function() {
        clearInterval(this.interval);
        this.set("running", false);
    },

    reset: function() {
        this.endTimer();
        this.startTimer(this.findStartTime());
    },

    toggle: function() {
        if(this.get('running') == true) {
            this.endTimer();
        } else {
            this.reset();
        }
    },

    findStartTime: function() {

        var timer = this;
        var date = new Date();
        var defaultStartTime = new Date(Date.parse($('#track_calendar_container').data('working-day-start-time')));
        var startTime = moment(date).format("YYYY-MM-DD") + 'T' + moment(defaultStartTime).format("HH:mm"); // Default start time

        var lastDayTiming = null;

        window.Track.grid.collection.each(function(model) {
            endTime = new Date(Date.parse(model.get('ended_at')));
            if(moment(endTime).format("YYYY-MM-DD") == moment(date).format("YYYY-MM-DD")) {
                lastDayTiming = model;
            }
        });

        if(lastDayTiming != null) {
            startTime = moment(lastDayTiming.get('ended_at')).add('minutes', 1).format("YYYY-MM-DDTHH:mm");
        }

        return startTime;
    }
});
