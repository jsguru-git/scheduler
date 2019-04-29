/*global _ Track track Backbone moment log */

/*
 * The team view represents the top level UI of the team application
 *
 */

track.ns( 'view' );

track.view.Team = Backbone.View.extend({

    transientModels: [], // stores models that are not yet saved

    ghostInitialPos: null,

    initialize: function(options) {

        _.extend(this, options);

        this.mouseDown   = false;
        this.gridOffset  = this.el.offsetTop;
        this.users       = this.getUsers();
        this.projects    = null;
        this.mouseStartY = null;
        this.mouseEndY   = null;
        this.upperBound  = null;
        this.lowerBound  = null;

        Track.fetchProjects(_.bind(this.onProjectsLoaded, this));

        // Scroll to start of users day
        track.util.scrollToDayStart();
        // Fix z-index bug on calendar show
        track.lib.zIndexFix();

        new track.view.CurrentTime({el: this.el});
    },

    /**
     * On projects loaded, render
     *
     * @param projects {track.collection.Project}
     */
    onProjectsLoaded: function(projects) {

        this.projects = projects;

        this.render();
    },

    /**
     * Get an array of current users
     *
     * @return {array}
     *
     */
    getUsers: function() {

        return $('.user_name').map(function(idx, user){
            return $(user).data('uid');
        });
    },

    getTimingsForUser: function(user_id) {

        return new track.collection.Timings({}, this.getParams(user_id));
    },

    getParams: function(user_id) {

        return { user_id : user_id,
                 start_date : Track.start(),
                 end_date : Track.start() };
    },

    render: function() {

        _.each(this.users, _.bind(function(id) {
            var timingsCollection = this.getTimingsForUser(id);
            timingsCollection.fetch({success: _.bind(function(collection) {
                collection.each(_.bind(function(model){
                    this.addOne(model);
                }, this));
            }, this)});
        }, this));
    },

    addOne: function(entry) {

        this.clearTransientModels();

        if(entry.isNew()) {
            // Fixes errors where end time is before start time
            track.lib.catchNegativeTime(entry);
            this.addTransientModel(entry);
        }

        var view = new track.view.TeamTiming({model: entry,
                                              projects: this.projects});
        view.render();
    },

    events: {
        "mouseenter #track_calendar"                  : "hideSelectors",
        "click .selector"                             : "onSelectorClick",
        "mousedown #inner_timing_grid .day_container" : "onClick",
        "mousemove #inner_timing_grid .day_container" : "onMouseMove",
        "mouseup #inner_timing_grid .day_container"   : "onMouseUp",
        'touchstart #inner_timing_grid .day_container': 'onClick',
        'touchmove #inner_timing_grid .day_container' : 'onMouseMove',
        'touchend #inner_timing_grid .day_container  ': 'onMouseUp'
    },

    /**
     * Removes any models that haven't been saved
     *
     */
    clearTransientModels: function() {

        _.each(this.transientModels, function(model) {

           if (model.isNew()) {
               model.destroy();
           }
        });
        this.transientModels = [];
    },

    /**
     * Create a new model and pass in information about the
     * grid position based on where a user clicked
     *
     */
    createTimeEntry: function(user_id, start, end, startDate) {

        var order      = track.lib.sortParams(start, end),
            x1         = order[0],
            x2         = order[1];

        var startTime  = track.util.convertOffsetToTime(track.util.roundToNearest(x1)),
            endTime    = track.util.convertOffsetToTime(track.util.ensureSafeHeight(x2)),
            format     = moment(startDate).format("MMMM D YYYY"),
            modelStart = moment(format + " " + startTime, "MMMM D YYYY hh:mm"),
            modelEnd   = moment(format + " " + endTime, "MMMM D YYYY hh:mm"),
            model      = new track.model.Timing({});

        model.set('started_at', track.lib.timeWithoutZone(modelStart.toString()));
        model.set('ended_at', track.lib.timeWithoutZone(modelEnd.toString()));
        model.set('user_id', user_id);

        this.addOne(model);

        var config = { model: model,
                       date: startDate,
                       collection: this.collection };

        new track.view.Editor(config, true);
    },

    hideSelectors: function(){

        $('.select_options').hide();
    },

    /**
     * Destroy all transients and all models that match for the day selected
     * Event triggered from the drop down menu 'clear' option
     * If no param is supplied then use the event target to determine the
     * required date to clear
     *
     * @param {string} d
     *   an optional date string YYYY-MM-DD (will clear all entries for that date)
     *
     */
    clearGrid: function(d){

        this.clearTransientModels();

        var date;
        // If a date param is supplied use that else use the event target to determine it
        if(typeof arguments[0] === 'string') {
            date = d;
        } else {
            date = this.getDateFromEventClick(arguments[0]);
        }
        // Find models that match on the date
        var matches = _.filter(this.collection.models, function(model){
            var d = moment(model.get('started_at')).format("YYYY-MM-DD");
            return d === date;
        });

        _.each(matches, function(match) { match.destroy(); });

        Track.flashSuccess("Entries for " + date + " cleared");
    },

    onSelectorClick: function(event) {

        $(event.target).parents('.header')
                       .find('.select_options')
                       .show();
        return false;
    },

    /*
     * The transient model array holds reference to models that have not yet
     * been saved. We need to clear out unsaved models to prevent the user
     * adding more than one temporary model at a time.
     */
    addTransientModel: function(model) {

        this.transientModels.push(model);
    },

    getTransientModels: function() {

        return this.transientModels;
    },

    addGhostDiv: function(event) {

        this.ghostInitialPos = track.util.timeFromClick(event);
        // Basically we just want a div to outline the select area
        $(event.target).append('<div class="ghost">' +
                               '<div class="time_indicator"></div></div>');

        $('.ghost').css('top', this.ghostInitialPos);
    },

    removeGhostDiv: function() {

       $('.ghost').remove();
    },

    getUserFromEvent: function(event) {

        var idx = $(event.currentTarget).index('#track_calendar .day_container');
        return $('.user_name').eq(idx).data('uid');
    },

    // MOUSE EVENTS ------------------------------------------------

    onClick: function(event) {

        // Hide the editor ?
        $('.time-editor').remove();

        if (event.target.className === 'day_container') {

            this.mouseDown   = true;
            this.mouseStartY = track.util.timeFromClick(event);
            this.clearTransientModels();
            this.addGhostDiv(event);

            var bounds = track.lib.getBounds(this.ghostInitialPos);
            this.upperBound = bounds[0];
            this.lowerBound = bounds[1];
        }
    },

    onMouseMove: function(event) {

        if(this.mouseDown == true) {
            var current          = track.util.timeFromClick(event),
                res              = Math.abs(this.ghostInitialPos - current),
                ghost            = $('.ghost');

            var args = [ghost,
                        current,
                        this.ghostInitialPos,
                        this.upperBound,
                        this.lowerBound,
                        res];

            track.util.showIndicator(this.mouseStartY, current);

            track.lib.ensureGhostBounds.apply(this, args);
        }
    },

    onMouseUp: function(event) {

        if (this.mouseDown === true) {
            this.mouseDown = false;
            this.mouseEndY = track.util.timeFromClick(event);

            var start = parseInt($('.ghost').css('top'), 10),
                end   = start + parseInt($('.ghost').height(), 10),
                date  = $('#track_calendar_container').data('startdate'),
                user = this.getUserFromEvent(event);

            if (user) {
                this.createTimeEntry(user, start, end, date);
            }

        }

        this.removeGhostDiv();
    },

    onMouseLeave: function(event) {

        this.mouseDown = false;
    }
});

