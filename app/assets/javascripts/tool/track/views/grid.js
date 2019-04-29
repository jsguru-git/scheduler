/*global _ Track track Backbone moment alert log main_notification */

/*
 * The grid view represents the top level UI of the application
 *
 */

track.ns( 'view' );

track.view.Grid = Backbone.View.extend({

    transientModels: [], // stores models that are not yet saved
    nextGapTime: null,
    ghostInitialPos: null,
    timings: null,

    initialize: function(options) {

        _.extend(this, options);

        this.mouseDown   = false;
        this.gridOffset  = this.el.offsetTop;
        this.projects    = null;
        this.mouseStartY = null;
        this.mouseEndY   = null;
        this.upperBound  = null;
        this.lowerBound  = null;
        this.dateTarget  = null; // Feature request #17562

        Track.fetchProjects(_.bind(this.onProjectsLoaded, this));

        track.util.scrollToDayStart();
        track.lib.zIndexFix();

        this.bindEvents();

        new track.view.CurrentTime({el: this.el});
    },

    /**
     * On projects loaded, show grid
     *
     * @param projects {track.collection.Project}
     */
    onProjectsLoaded: function(projects) {

        this.projects = projects;

        this.hideOverlay();
        this.render();
    },

    hideOverlay: function() {

        $('.modal_overlay').hide();
    },

    render: function() {

        var collection = this.collection;

        collection.fetch({
            success: _.bind(function(collection) {
                collection.each(_.bind(function(m) {
                    this.addOne(m);
                }, this));

                $('.day_statistics').each(function(el, idx) {
                    new track.view.DayStatistics({
                        collection: collection,
                        el: idx
                    });
                });

            }, this)
        });
    },

    events: {
        "mouseenter #track_calendar"                  : "hideSelectors",
        "mouseleave #title_grid"                      : "hideSelectors",

        "click .selector"                             : "onSelectorClick",
        "click .date_number"                          : "onSelectorClick",
        "click .do_clear"                             : "clearGrid",
        "click .do_reset"                             : "resetFromSchedule",
        "click .do_copy"                              : "showCopyModal",
        "mousedown"                                   : "stopTimer",
        "open .time-editor #time-edit .project"       : "stopTimer",

        "mousedown #inner_timing_grid .day_container" : "onClick",
        "mousemove #inner_timing_grid .day_container" : "onMouseMove",
        "mouseup #inner_timing_grid .day_container"   : "onMouseUp",

        'touchstart #inner_timing_grid .day_container': 'onTouchStart',
        'touchmove #inner_timing_grid .day_container' : 'onMouseMove',
        'touchend #inner_timing_grid .day_container  ': 'onMouseUp'
    },

    stopTimer: function() {
        window.Track.timer.endTimer();
    },

    onTouchStart: function(event) {
        event.preventDefault();
        this.onClick(event);
    },

    /**
     * Based on where the user clicked, return the column
     *
     */
    calculateColumn: function(event) {

        return event.currentTarget;
    },

    /**
     * Used to reverse start and end params if the user swipes
     * backwards (i.e a reverse swipe)
     *
     */
    sortParams: function(start, end) {
        var a, b;
        if (start < end) {
            a = start;
            b = end;
        } else {
            a = end;
            b = start;
        }
        return [a, b];
    },

    /**
    * Finds the next gap of a certain size
    */
    nextGap: function(size, timing) {
        var models = timing.models;
        for(var x = 0; x < models.length -1; x++) {
            var end = moment(models[x].ended_at);
            var start = moment(models[x+1].started_at);
            var gap = start.diff(end, 'minutes') - 1;

            if(gap >= size)
            {
                return models[x].ended_at;
            }
        }
        return models[models.length - 1].ended_at;
    },

    /**
    * Returns a boolean based on whether or not two times overlap
    */
    overlap: function(time, timing, end) {
        return _.filter(timing.models, _.bind(function(model) {
            var started = moment.utc(model.started_at, 'YYYY-MM-DDTHH:mm:ssZ');
            var ended = moment.utc(model.ended_at, 'YYYY-MM-DDTHH:mm:ssZ');
            var newTime = track.util.convertOffsetToTime(time).split(":");

            var radixBase = 10;

            var concatTime = parseInt(newTime[0] + "" + newTime[1], radixBase);
            var startedTime = parseInt(started.hour() + "" + started.format('mm'), radixBase);
            var endedTime = parseInt(ended.hour() + "" +ended.format('mm'), radixBase);
            if(concatTime > startedTime && concatTime < endedTime)
            {
                this.nextGapTime = this.nextGap(end - time, timing);
                return true;
            } else {
                return false;
            }
        }, this));
    },

    /**
     * Create a new model and pass in information about the
     * grid position based on where a user clicked
     *
     */
    createTimeEntry: function(start, end, startDate, event) {

        var timings = new track.collection.Timings({}, {
            user_id: Track.user(),
            start_date: moment(startDate).format("YYYY-MM-DD"),
            end_date: moment(startDate).format("YYYY-MM-DD")
        });

        timings.fetch({
            success: _.bind(function() {

                var order      = this.sortParams(start, end),
                startTime  = track.util.convertOffsetToTime(order[0]),
                endTime    = track.util.convertOffsetToTime(order[1]),
                format     = moment.utc(startDate).format("MMMM D YYYY"),
                model = new track.model.Timing();

                var start_full = moment(format + " " + startTime);
                var end_full = moment(format + " " + endTime);

                if(this.overlap(start, timings, end).length > 0) {
                    var lastTime = this.overlap(start, timings, end)[this.overlap(start, timings, end).length - 1];
                    var offset = moment.utc(lastTime).subtract(start_full);

                    start_full = moment.utc(this.nextGapTime).add({
                        minutes: 1
                    });

                    end_full = moment.utc(end_full).add({
                        minutes: offset.minutes()
                    });
                }

                start_full = start_full.format("YYYY-MM-DDTHH:mm");
                end_full = end_full.format("YYYY-MM-DDTHH:mm");

                model.set('started_at', start_full);
                model.set('ended_at', end_full);
                model.set('temporary_collection', this.collection);
                this.addOne(model);

                new track.view.Editor({ model:      model,
                                        date:       startDate,
                                        collection: this.collection });

            }, this)
        });
    },

    createTimerEntry: function(startAt, endAt) {
        var date  = new Date();
        var model = new track.model.Timing();

        model.set('started_at', startAt);
        model.set('ended_at', endAt);
        model.set('temporary_collection', this.collection);
        this.addOne(model);

        new track.view.Editor({ model:      model,
                                date:       moment(date).format("YYYY-MM-DD"),
                                collection: this.collection });

    },

    addGhostDiv: function(event) {

        this.ghostInitialPos = track.util.timeFromClick(event);

        $(event.target).append('<div class="ghost">' +
                               '<div class="time_indicator"></div></div>');

        $('.ghost').css('top', this.ghostInitialPos);
    },

    removeGhostDiv: function() {

       $('.ghost').remove();
    },

    onClick: function(event) {

        var target = $(event.target);
        var canAddTiming = Track.admin() || !target.data('submitted');

        $('.time-editor').remove();

        if (target.hasClass('day_container') && canAddTiming) {

            this.mouseDown   = true;
            this.mouseStartY = track.util.timeFromClick(event);
            this.dateTarget = event.currentTarget;
            this.clearTransientModels();
            this.addGhostDiv(event);

            var bounds = track.lib.getBounds(this.ghostInitialPos);

            this.upperBound = bounds[0];
            this.lowerBound = bounds[1];
        }
    },

    /**
     * TODO 1. This shouldn't be called every time the mouse moves as it's expensive
     *      2. Fix height correctly
     *      3. Bind the mouse up event to use the ghost size instead of position
     *      4. Catch overshoot from fast mouse movement
     */
    onMouseMove: function(event) {

        if (this.mouseDown == true) {
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
        var ghostExists = ($('.ghost').length > 0);
        if (this.mouseDown === true && ghostExists) {
            this.mouseDown = false;
            this.mouseEndY = track.util.timeFromClick(event);
            var start = parseInt($('.ghost').css('top'), 10),
                end   = start + parseInt($('.ghost').height(), 10),
                date  = track.util.getColumnDate(this.dateTarget);

            this.createTimeEntry(start, end, date, event);
        }

        $('.time_indicator').hide();

        this.removeGhostDiv();
    },

    onMouseLeave: function(event) {

        this.mouseDown = false;
    },

    getDateFromEventClick: function(event) {

        var idx = $(event.target).parents('.header')
                                 .index('.header');

        return $("#inner_timing_grid .day_container").eq(idx)
                                                     .data('columnDate');
    },

    /**
     * Destroy all transients and all models that match for the day selected
     * Event triggered from the drop down menu 'clear' option
     * If no param is supplied then use the event target to determine the
     * required date to clear
     *
     * @param {string} dateString
     *   an optional date string YYYY-MM-DD (will clear all entries for that date)
     *
     */
    clearGrid: function(dateString) {

        this.clearTransientModels();

        var date;

        if(typeof arguments[0] === 'string') {
            date = dateString;
        } else {
            date = this.getDateFromEventClick(arguments[0]);
        }

        var target = ".day_container[data-column-date='" + date + "']";

        $(target).each(function(idx, col) {
            $(col).find('.entry').remove();
        });

        this.collection.fetch({
            success: function(collection) {
                collection.each(function(timing){
                    if(moment(timing.get('started_at')).format('YYYY-MM-DD') == date) {
                        timing.destroy({wait: true});
                    }
                });
            }
        });

        return false;
    },

    /**
     * Removes and redraws entries
     *
     * @param {string} dateString
     *   an optional date string YYYY-MM-DD (will clear all entries for that date)
     *
     */
    refresh: function() {

        this.clearTransientModels();

        $('.day_container.column').each(function(idx, col) {
            $(col).find('.entry').remove();
        });

        this.render();
    },

    /**
     * Returns array of models on the grid matching a given date
     *
     * @param {string} date date in format YYYY-MM-DD
     * @return {array}
     */
    modelsMatchingDate: function(date, values, copy) {
        var timings = new track.collection.Timings({}, {
            start_date: date,
            end_date: date,
            user_id: Track.user()
        });
        timings.fetch({
            success: _.bind(function(timings) {
                var collection = _.filter(timings.models, function (model) {
                    return date === moment(model.get('started_at')).format("YYYY-MM-DD");
                });
                if(copy) {
                    this.parseCollection(collection, values);
                }
            }, this)
        });
    },

    /**
     * Display the copy day modal window
     * Picks up the date from event in format YYYY-MM-DD
     *
     * @return {void}
     */
    showCopyModal: function(event) {

        var date = this.getDateFromEventClick(arguments[0]);

        return new track.view.Modal({el: '.copy_timesheet',
                                     view: this,
                                     date: date});
    },

    /**
    * Copy entries
    */
    parseCollection: function(collection, values) {
        if (collection.length > 0) {
            this.copyEntries(collection, values.start, values.end);
        } else {
            alert("No entries found for " + values.start);
        }
    },

    /** Dispatch */
    handleValues: function(values) {
        var models = this.modelsMatchingDate(values.start, values, true);
    },

    /**
     * Serious hackery to bump dates
     *
     * @param {string} from MUST be in format 2012-12-19T03:15:00Z
     * @return {string}
     *
     */
    changeDate: function(from, to) {

        return [to, from.split('T')[1]].join('T');
    },

    /**
     * Check if we can copy entries to a given date.
     * If entries for given date have been submitted return false else true
     * @param {string} to format YYYY-MM-DD e.g '2013-01-08'
     * @return {boolean}
     */
    canCopyEntries: function(to) {

        var column = $('.day_container[data-column-date="' + to + '"]'),
            submitted = column.data('submitted');

        return submitted === true ? false : true;
    },

    /**
     * Copy models to a given date
     *
     * @param {} models
     * @param {string} from format YYYY-MM-DD
     * @param {string} to format YYYY-MM-DD
     *
     */
    copyEntries: function(modelsArray, from, to) {

        var canCopy = this.canCopyEntries(to);

        // Fetch the data again to make sure we're up to date.

        this.collection.fetch({success:_.bind(function(models) {
            if (canCopy) {
                this.clearGrid(to);

                _.each(modelsArray, _.bind(function(model) {
                    var start = this.changeDate(model.get('started_at'),to),
                        end   = this.changeDate(model.get('ended_at'), to),
                        task  = model.get('task_id'),
                        project = model.get('project_id');
                    this.createNewModel(start, end, project, task);
                }, this));
            } else {
                alert("You cannot copy to a day that has been submitted ");
            }
        }, this)});
    },

    /**
     *
     * Creates a new model instance and saves it
     * @param {} start
     * @param {} end
     * @param {number} project_id
     */
    createNewModel: function( start, end, project_id, task ) {

        var model = new track.model.Timing();

        model.set('started_at', start);
        model.set('ended_at', end);
        model.set('project_id', project_id);
        model.set('user_id', Track.user());
        model.set('task_id', task);

        model.save({}, {success: _.bind(function(){
            this.addOne(model);
            this.collection.add(model);
        }, this)});
    },

    /**
     * Returns a full date
     *
     * @param {} time
     * @param {} date
     * @return {string}
     *
     */
    generateFullDate: function(time, date) {

        return moment(date + "T" + time + ":00Z").toString();
    },

    /**
     * Finds entries from schedule and applies them to the grid
     *
     */
    applyEntriesFromSchedule: function(entries, date) {

        var total = entries.length,
            times = track.util.dividePairs(total);

        entries.each(_.bind(function(entry, idx) {
            var start = this.generateFullDate(times[idx][0], date),
                end   = this.generateFullDate(times[idx][1], date);
            this.createNewModel(start, end, entry.get('project').id);
        }, this));
    },

    onKeyUp: function(event) {
        if(event.keyCode == 27){
            this.removeGhostDiv();
        }
    },

    /**
     * Returns suitable params in an object
     *
     * @param {} date
     * @return {object}
     */
    getParamsForEntries: function(date) {

        return { user_id    : Track.user(),
                 start_date : date,
                 end_date   : date };
    },

    /**
     * Clears out all existing entries and creates new ones based on
     * data in the calendar. Tries to dispurse entries evenly for the day
     *
     * @param {jQuery event} e
     */
    resetFromSchedule: function(e) {

        var date    = this.getDateFromEventClick(e),
            params  = this.getParamsForEntries(date),
            entries = new track.collection.Entries({}, params);

        entries.fetch({success: _.bind(function() {
            if(entries.length === 0) {
                alert("No entries scheduled for today");
            } else {
                this.clearGrid(date);
                this.applyEntriesFromSchedule(entries, date);
            }
        }, this)});

        return false;
    },

    hideSelectors: function() {

        $('.select_options').hide();
    },

    onSelectorClick: function(event) {

        event.preventDefault();
        this.hideSelectors();
        $('#title_grid .day_container').css('z-index', 1000);
        $(event.target).parents('.header').find('.select_options').show();
        return false;
    },

    /**
     * The transient model array holds reference to models that have not yet
     * been saved. We need to clear out unsaved models to prevent the user
     * adding more than one temporary model at a time.
     *
     * @param {} model
     * @return void
     */
    addTransientModel: function(model) {

        this.transientModels.push(model);
    },

    getTransientModels: function() {

        return this.transientModels;
    },

    /**
     * Removes any models that haven't been saved
     *
     */
    clearTransientModels: function() {

        _.each(this.transientModels, function(model) {
           if( model.isNew() ) { model.destroy(); }
        });

        this.transientModels = [];
    },

    addOne: function(entry) {

        this.clearTransientModels();

        if(entry.isNew()) {
            // Fixes errors where end time is before start time
            track.lib.catchNegativeTime(entry);
            this.addTransientModel(entry);
        }
          var view = new track.view.Timing({ model: entry,
                                             projects: this.projects });
          view.render();
    },

    addAll: function() {
        this.collection.each(function(model) {
            this.addOne(model);
        });
    },

    getModelIdFromEvent: function(e) {
        return $(e.currentTarget).parents('.entry')
                                 .data('modelId');
    },

    submitDay: function(submitDate){
        var grid = this;
        var result;
        var submit = window.confirm('Are you sure you want to submit?');
        if(submit == true) {
            $.ajax({
                url: '/track/timings/submit_time',
                type: 'POST',
                async: false,
                data: { user_id: Track.getParams().user_id, date: submitDate },
                success: function() {
                    grid.refresh();
                    result = true;
                    main_notification.display_message('Submitted time successfully');
                },
                error: function(e) {
                    main_notification.display_message('Failed to submit time');
                    result = false;
                }
            });
        }
        return result;
    },

    /**
     * Bind general events outside the scope of backbone element
     */
    bindEvents: function() {

        $(document).on('keydown', _.bind(function(event) {
            this.onKeyUp(event);
        }, this));

        var grid = this;

        $('.day_container .submit').click(function(){
            if(grid.submitDay($(this).parents('.day_container.summary').data('date'))) {
                $(this).parents('.day_container.summary').append("<div class='submitted'></div>");
                $(this).remove();
            }
            return false;
        });

    }
});

