/*global main_lightbox _ Track track Backbone moment JST */

track.ns( 'view' );

track.view.DayStatistics = Backbone.View.extend({

    template: JST["tool/track/templates/day_statistics"],

    initialize: function(options, parent) {
        _.extend(this, options);

        this.$el.appendTo(parent);

        this.collection.on("remove", this.render, this);
        this.collection.on("change", this.render, this);
        this.collection.on("add", this.render, this);

        this.render();
    },

    render: function() {
        var currentTracked = this.timeTracked();

        this.tracked = this.formatTime(currentTracked);
        this.flexiAccrued = this.formatTime(currentTracked - this.$el.data('expected-timings'));
        this.$el.html(this.template(this));

    },

    timeTracked: function() {
        return this.collection.trackedMinutes(this.$el.data('date'));
    },

    formatTime: function(trackedMinutes) {
        var negative = false;
        var hours = 0;


        if(trackedMinutes < 0) {
            negative = true;
        }

        if(negative){
            hours = Math.ceil(trackedMinutes / 60);
        }
        else {
            hours = Math.floor(trackedMinutes / 60);
        }

        var minutes = Math.abs(trackedMinutes % 60);


        if(trackedMinutes == 0){
            return 0;
        }
        else {
            var result = "";
            if(negative) { result += "-"; }
            result += Math.abs(hours) + 'h ' + minutes + 'm';

            return result;
        }
    }

});
