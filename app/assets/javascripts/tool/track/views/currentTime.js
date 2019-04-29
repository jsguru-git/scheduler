/*global track _ Backbone */

track.ns( 'view' );

track.view.CurrentTime = Backbone.View.extend({

    timeEl: null,

    initialize: function(options) {

        this.timeEl = $('<div></div>')
            .addClass('current_time');

        $.extend(this, options);
    },

    events: {
        "mouseenter .day_container" : "show",
        "mouseleave .day_container" : "hide",
        "mousemove .day_container"  : "onMouseMove",
        "mousedown .day_container"  : "hide"
    },

    show: function() {

        this.timeEl.appendTo('#time_container_outer');
    },

    hide: function() {

        this.timeEl.remove();
    },

    onMouseMove: function(event) {

        var offset = track.util.timeFromClick(event);
        var time = track.util.convertOffsetToTime(offset);
        var adjustment = 4; // pixel tweak to overlay on time exactly

        this.timeEl
            .html(time)
            .css('top', offset - adjustment);
    }
});

