/*global _ log track moment JST Track Backbone */

track.ns( 'view' );

track.view.TeamTiming = Backbone.View.extend({

    template: JST["tool/track/templates/timing"],

    initialize: function(options) {

        _.extend(this, options);

        this.start = $('#track_calendar_container').data('startdate');
        this.model.bind('destroy', this.remove, this);

        // If the model gets saved then update the view
        this.model.bind('sync', function(model, response, options) {
           this.getTask();
           var success = options.success;
           if (success) { this.reRender(); }
        }, this);

        // Rebind events when new elements get added to the grid.
        // Ask for a code review on this. Wary of recursion here
        $(this.$el).delegate('.entry', 'mouseover', _.bind(function() {
            this.bindEvents.call(this);
        }, this));
    },

    events : {

        "click a.remove-entry" : "removeOne",
        "click a.edit-entry"   : "editEntry",
        "dblclick"             : "editEntry"
    },

    // Cache the dom element here if possible
    element: function() {

        return this.$el.children('.entry');
    },

    removeOne: function(event) {

        var response = window.confirm("Are you sure you want to delete?");
        if (response == true)
        {
            this.model.destroy();
        }
        return false;
    },

    getColumn: function(user_id) {

        var col = $('#user-' + user_id).index('.user_name');
        return $('#track_calendar .day_container').eq(col);
    },

    /**
     * Sets the top offset of a timing element
     *
     */
    setPosition: function() {

        var offset = track.util.calculateOffset(this.model.get('started_at'));
        this.element().css('top', offset);
    },

    /**
     * Set the height of an element in pixels
     *
     */
    setHeight: function() {

         var h = track.util.entryHeight(this.model.get('started_at'),
                                        this.model.get('ended_at'));

         this.element().css('height', h);
    },

   /**
     * When a model moves on the grid, update time values in the editor window
     *
     */
    updateEditor: function(start, end) {

        $('input.started_at').val(start);
        $('input.ended_at').val(end);
    },

    /**
     * Sets the Y position of an element.
     *
     * @param {number} y css top offset
     */
    setY: function(y) {

        this.element().css('top', y);
    },

    /**
     * If an entry goes off course then reset it to a sensible position
     * The model validations require the start time to be even i.e 10:00
     * Bounces the element down by 1 pixel if it slips to a non even start time
     * like 09:59
     *
     */
    ensureSafePosition: function(event, currentPos) {

        var top = currentPos || this.model.calculateGridPosition(event);

        if(top % 5 !== 0) {
          this.setY(top+1);
        }
    },

    // Use recursion to reposition element
    reposition: function(pos) {

       if(pos % 5 === 0) {
           this.setY(pos);
           return;
       } else {
           this.reposition(pos - 1); // recur
       }
    },

    /**
     * Makes a full date string from a time t format HH:mm '20:23'
     *
     * @param {string} t
     *
     */
    fullString: function(t) {

        var str = track.util.fullDate(t, this.start);
        return track.lib.timeWithoutZone(str);
    },

    /**
     * When a time entry is changed on the grid, update the model
     * TODO this function is doing far too much. Refactor
     *
     */
    onMoveStop: function(event, el) {

        this.$el.find('.time_indicator').hide();

        var position = this.model.calculateGridPosition(event);

        track.lib.ensureSafePosition(this.$el, this);

        var topPosition = this.model.calculateGridPosition(event),
            startTime   = track.util.convertOffsetToTime(topPosition),
            height      = this.model.calculateHeight(event),
            endTime     = track.util.endTime(topPosition, (height + 1));

        this.model.set('started_at', this.fullString(startTime));
        this.model.set('ended_at', this.fullString(endTime));

        this.updateEditor(startTime, endTime);

        if(!this.model.isNew()){
          this.model.save(); // Update the model automatically
        }
    },

    /**
     * When user drags and entry give a visual indicatioon of the start time
     *
     */
    onDrag: function(event) {

       $('.tooltip').hide();

       this.$el.find('.time_indicator').show();

       var topPosition = this.model.calculateGridPosition(event),
           height      = this.element().outerHeight(),
           time        = track.util.convertOffsetToTime(topPosition),
           end_time    = track.util.endTime(topPosition, height);

       this.$el.find('.time_indicator').html(time + " - " + end_time);
    },

    /**
     * Gets the color directly from the json on first load
     *
     * @param {object} model Backbone.js model
     *
     */
    getColor: function(model) {

        var project, color="#ccc";

        if (!model.isNew()) {
            if (model.project) {
                color = model.project.color.toString();
            } else {
                project = this.getProjectFromModel(model);
                color = project.get('color');
            }
        }

        return color;
    },

    setColor: function() {

        this.element().css('background', this.getColor(this.model));
    },

    /**
     * If a model has a task then return it else return 'No task'
     *
     * @return {string}
     *
     */
    getTask: function() {

        var task="";

        try {

            if (this.model.get('task_id')){

                var project = this.projects.get(this.model.get('project_id')),
                    task_id = this.model.get('task_id'),
                    tasks   = project.get('tasks'),
                    results = _.filter(tasks, function(t) {
                        return t.id == task_id;
                    });

                task = results[0].name;

            } else {
                task = "No task";
            }
        } catch (e) { }

        return task;
    },

    /**
     * Return the project name or "New project" if there is no project set
     *
     * @return {string} project name
     */
    projectName: function() {

        var project = "";
        if (this.model.project) {
            project = this.model.project.name;
        } else {
            try {
                project = this.getProjectFromModel(this.model).get('name');
            } catch (e) { }
        }
        return project;
    },

    /**
     * Appends element to the DOM
     *
     */
    addToGrid: function() {

        this.$el.html(this.template(
            {model: this.model,
             project : this.projectName(),
             id: this.model.id || 0,
             task: this.getTask() || ""}));

        $(this.getColumn(this.model.get('user_id'))).prepend(this.el);
    },

    editEntry: function(event) {

        var started = this.model.get('started_at');
        var date;

        if (started.split(' ').length > 1) {
            date = moment(started.split(' ')
                                     .slice(0,3)
                                     .join(' ')).format("YYYY-MM-DD");
        } else {
            date = started.split('T')[0];
        }

        var config = { model: this.model,
                       date: date };

        new track.view.Editor(config, true);

        return false;
    },

    getProjectFromModel: function(model) {

        if (model) {
            var pid = model.get('project_id');
            return this.projects.get(pid);
        } return null;
    },

    setTask: function() {

         var task = this.getTask();
         this.element().find('.task_title').html(task);
    },

    /**
     * Set the title of an entry to the models current title
     */
    setTitle: function() {

        if(this.getProjectFromModel(this.model)){
            var title = this.getProjectFromModel(this.model).get('name');
            this.element().find('.project_title').html(title);
        }
    },

    // When a model gets updated in the editor or grid update dom
    reRender: function() {

        this.setColor();
        this.setTitle();
        this.setPosition();
        this.setHeight();
        this.setTask();
    },

    render: function() {

        this.addToGrid();
        this.bindEvents();
        this.setColor();
        this.setPosition();
        this.setHeight();
        this.setTitle();
        track.lib.onResize(this.element());
    },

    /**
     * Bind draggable events and collision detection
     *
     */
    bindEvents: function() {

        var self      = this,
            parent    = this.$el.parents('.day_container');

        track.lib.showToolTips(this.$el, this.model);

        if (Track.admin() || !this.model.get('submitted')) {
            var opts = {
              axis: "y",
              stop: function(event, ui) {
                  self.onMoveStop(event, this);
              },
              drag: function(event) { self.onDrag(event); },
              containment: "#inner_timing_grid",
              obstacle: parent.find('.entry').not(this.element()),
              preventCollision: true };
            $(this.element()).draggable(opts).resizable({
                handles: 's',
                resize: _.bind(function(event, ui) {
                    track.lib.restrictSize(ui);
                    track.lib.onResize(this.element());
                    self.onDrag(event);
                }, this),
                stop: function(event) {
                   self.onMoveStop(event, this);
                }
            });
        }
    }
});

