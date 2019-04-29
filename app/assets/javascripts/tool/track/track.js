/*global _ Track moment JST log track Backbone */

(function() {

    /*
     * Global object that initializes the views and sets up the app
     *
     */
    window.Track = {

        projects: null,
        grid: null,

        /**
         * Fetch all projects and pass backbone collection to callback
         *
         * @param callback {function}
         */
        fetchProjects: function(callback) {

            var onLoad = _.bind(
                function() {
                    callback(this.projects);
                },
                this
            );

            if (this.projects) {
                onLoad();
            } else {
                this.projects = new track.collection.Projects({}, {
                    user_id: Track.user()
                });
                this.projects.fetch({success: onLoad});
            }
        },

        start: function() {

            return $('#track_calendar_container').data('startdate');
        },

        end: function() {

            return $('#track_calendar_container').data('enddate');
        },

        /**
         * Checks if user iPad is being used.
         * @return {boolean}
         *
         */
        iPad: function() {

            return navigator.userAgent.match(/iPad/i) != null;
        },

        /**
         * Current user id
         *
         */
        user: function() {

            return $('#track_calendar_container').data('userid');
        },

        users: function() {

            var collection = new track.collection.Users();
        },

        /**
         * Check if the current user is an administrator
         *
         * @return {boolean}
         */
        admin: function() {

            return $('#track_calendar_container').data('admin');
        },

        /**
         * Will extract a time stamp from the DOM in format hh:mm:ss
         *
         */
        parseTimeAttr: function(attr) {

            var t = $('#track_calendar_container').data(attr);

            return t.split(' ')[1];
        },

        /**
         * @return {string} timestamp format "hh:mm:ss"
         *
         */
        dayStart: function() {

            return Track.parseTimeAttr('workingDayStartTime');
        },

        /**
         * @return {string} timestamp format "hh:mm:ss"
         *
         */
        dayEnd: function() {

            return Track.parseTimeAttr('workingDayEndTime');
        },

        /**
         * Returns the length of a working day in minutes
         * @return {number} duration of working day in minutes
         *
         */
        workingDay: function() {

            var format = "hh:mm:ss",
                start = moment.utc(Track.dayStart(), format),
                end = moment.utc(Track.dayEnd(), format);

            return Math.abs(end.diff(start, 'minutes'));
        },

        /**
         * Returns the correct params for the grid
         * start_date, end_date and user_id
         *
         */
        getParams: function() {

            return {
                user_id: Track.user(),
                start_date: Track.start(),
                end_date: Track.end()
            };
        },

        flash: function(type, msg) {

            var tmpl = JST["tool/track/templates/flash"]({
                type: type,
                msg: msg
            });

            $('.flash_notification').hide().html(tmpl);
            $('.flash_notification').slideDown(function(){
                $(this).delay(3000).slideUp();
            });
        },

        flashError: function(msg) {

            return _.bind(Track.flash, {}, 'bad', msg).call();
        },

        flashSuccess: function(msg) {

            return _.bind(Track.flash, {}, 'good', msg).call();
        },

        /**
         * Set the grid width for team view to overflow
         *
         */
        setGridWidth: function() {

            var first_col = $('.time_container_inner').outerWidth(),
                count = $('#track_calendar .day_container').size(),
                container_width = $('.day_container').outerWidth(),
                limit = 5;

            var width = (function() {

                if (count > limit) {
                    return first_col + ((count + 1) * container_width);
                } else {
                    return container_width;
                }
            }());

            if (count > limit) {
                $('#title_grid').width(width);
                $('#track_calendar').width(width);
            }
        },

        /**
         * Common init between team/grid views
         *
         */
        initCommon: function() {

            var ESCAPE = 27;

            $(window).onkey(
                ESCAPE,
                _.bind(this.hideEditor, this)
            );
        },

        /**
         * Try and hide all track editors
         *
         */
        hideEditor: function() {

            var editors = $('.time-editor');

            if (editors.length) {
                editors.data('editor')
                       .hide();
            }
        },

        /**
         * Initialize the team view. This is called from a script tag
         * at the bottom of app/views/timings/_user_view.html.erb.
         * This is the main application entry point for the team view
         *
         */
        initTeamView: function() {

            this.initCommon();

            Track.setGridWidth();

            $(window).bind('resize', Track.setGridWidth());

            new track.view.Team({
                el: $('#track_calendar_container')
            });
        },

        /**
         *
         * In Firefox scroll bars cause grid columns and headers
         * to be misaligned
         *
         */
        fixScrollBarWidths: function() {

            var iwidth = $('#title_grid .header').width();
            $('#inner_timing_grid .day_container').width(iwidth + 1);
        },

        /**
         * Initialize timesheet view. This is called from a script
         * tag at the bottom of app/views/timings/_team_view.html.erb.
         * This is the main application entry point for the time view.
         *
         */
        initTimesheetView: function() {

            this.initCommon();
            this.highlight_today();

            var timings = new track.collection.Timings({}, Track.getParams());
            this.grid = new track.view.Grid({
                uid: Track.user(),
                collection: timings,
                el: $('#track_calendar_container')
            });
        },

        /**
        * Updates the header to highlight today's date
        */
        highlight_today: function() {
            $('.day_container.header').removeClass('today');
            $('.day_container.header').each(function(idx, element) {
                if($(element).data('date') == moment().format('YYYY-MM-DD')) {
                    $(element).addClass('today');
                }
            });

        }
    };

})($, window);
