/*global track _ Backbone */

track.ns( 'view' );

track.view.TimerToggle = Backbone.View.extend({

    initialize: function(options) {
        _.extend(this, options);

        this.render();

        this.model.on('change:endTime', this.render());
    },

    events: {
        "click": "toggle"
    },

    toggle: function() {
        this.model.toggle();
    },

    updateDuration: function(running) {
        if (running) {
            var start = this.model.get('startTime');
            var now = moment(new Date()).format('YYYY-MM-DDTHH:mm');
            var duration = '00:00';
            var difference = moment(moment(now) - moment(start));

            if (difference > 0) {
                duration = moment(difference).format('HH:mm');
            }

            $('#duration', this.$el).html(duration);
        }
        else {
            $('#duration', this.$el).html('');
        }

    },


    updateStatus: function(running) {
        if (running) {

            $('#status', this.el).html('Stop Timer');
            $('#status', this.el).removeClass('on');
            $('#status', this.el).addClass('off');

        } else {

            $('#status', this.el).html('Start Timer');
            $('#status', this.el).removeClass('off');
            $('#status', this.el).addClass('on');
        }

    },

    render: function() {

        this.updateDuration(this.model.get('running'));
        this.updateStatus(this.model.get('running'));

    }
});

