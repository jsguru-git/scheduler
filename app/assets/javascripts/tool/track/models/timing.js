/*global _ log alert Track track Backbone moment */

track.ns ( 'model' );

track.model.Timing = Backbone.Model.extend({

    el: '#inner_timing_grid',

    DATE_FORMAT: "YYYY-MM-DD",

    TIME_FORMAT: "HH:mm",

    defaults: function() {

        return {
            notes: ""
        };
    },

    /**
     * Can be initialized with a start and end time
     * @param {object} opts
     *
     */
    initialize: function(opts) {

        _.extend(this, opts);

        _.bindAll(this, 'defaultErrorHandler');

        this.bind("error", this.defaultErrorHandler);

        // Bind save function to hide the modal editor
        this.bind('sync', function(model, response, options) {
            $(".time-editor").remove();
        });
    },

    /**
     * Converts a time string to pixels
     *
     * @return {number}
     */
    timeToPixelOffset: function () {

        var hours   = moment(this.get('started_at')).hours(),
            minutes = moment(this.get('started_at')).minutes();

        return (hours * 60) + minutes;
    },

    /**
    * Converts end time string to pixels
    *
    * @return {number}
    */
    endTimeToPixelOffset: function() {
        var hours   = moment(this.get('ended_at')).hours(),
            minutes = moment(this.get('ended_at')).minutes();

        return (hours * 60) + minutes;
    },

    /**
     * Height of a time entry in pixels
     *
     */
    calculateHeight: function(event) {

        return parseInt($(event.target).outerHeight(), 10) - 1;
    },

    /**
      * Returns the y position for a timing entry
      * This also takes into account the position of the scrollbar
      *
      */
    calculateGridPosition: function(event) {

        return parseInt($(event.target).css('top'), 10);
    },

    /**
     * Generates the correct url depending on the request type
     *
     * @param {string} method
     *
     */
    getURL: function(method) {

        // method either read, create, update or delete
        var url = '/track_api/timings';

        if (method === 'delete' || method === 'update') {
            url += '/' + this.get('id') + '.json';
        } else {
            url += '.json';
        }
        return url + '?user_id=' + this.get('user_id');
    },

    sync: function(method, model, options) {

        options     = options || {};
        options.url = model.getURL(method.toLowerCase());
        Backbone.sync(method, model, options);
    },

    /**
     * Clear out the flash error html
     *
     */
    clearErrors: function() {

        $('#flash_errors').html('');
    },


    /**
     * Takes a data property and make it more reader friendly
     * i.e convert started_at to Started at
     * @param {string} prop a validation string
     * @returns {string} formatted result
     */
    parseValidation: function(prop) {

       return (function() {
            var res = prop;
            switch(prop) {
                case "ended_at":
                    res = "End time";
                    break;
                case "started_at":
                    res = "Start time";
                    break;
                default:
                    res = prop;
            }
            return res;
        }());
    },

    /**
     * Spits the server errors back as HTML and inserts into the time form
     *
     */
    showErrors: function(errors) {

        var html = "",
            obj  = jQuery.parseJSON(errors);
        for( var prop in obj ) {
            if( Object.prototype.hasOwnProperty.call(obj, prop) ) {
                html += "<li>" + obj[prop] + "</li>";
            }
        }
        $('#time-errors').html(html);
        $('.submit-loader').hide();
    },

    /**
     * Gets called for failures in validation and for server failures.
     *
     */
    defaultErrorHandler: function(model, error) {

        var errors;
        if (_.isArray(error)) {
            errors = error.join(', ');
        } else {
            this.showErrors(error.responseText);
        }
    },

    /**
     * Returns the start date in the format YYYY-MM-DD
     * This function is used to determine which column to append an element
     *
     * @return {string} date string in format YYYY-MM-DD e.g 2012-11-01
     *
     */
    startDate: function() {

        return moment(this.get('started_at')).format("YYYY-MM-DD");

    },

    endDate: function() {

        return track.util.format(this.get('ended_at'),
                                 this.DATE_FORMAT);
    },

    startTime: function() {

        return track.util.format(this.get('started_at'),
                                 this.TIME_FORMAT);
    },

    endTime: function() {

        return track.util.format(this.get('ended_at'), this.TIME_FORMAT);
    },

    /**
     * Return the full date time i.e 2012-09-02 02:29
     *
     * @return {string}
     */
    fullDateTime: function(t) {

        return this.get('date') + " " + t;
    }
});

