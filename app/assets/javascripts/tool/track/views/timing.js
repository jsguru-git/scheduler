/*global _ log track JST moment Track Backbone */

/*
 * Delegates the rendering of a model on the grid
 * A model is rendered and automatically positions itself
 * based on the date, start_time and end_time
 *
 */

track.ns( 'view' );

track.view.Timing = Backbone.View.extend({

    template: JST["tool/track/templates/timing"],

    initialize: function(options) {

       _.extend(this, options);

       this.model.bind('destroy', this.remove, this);

       if(this.projects == undefined) {
           this.projects = window.Track.projects;
       }

       // If the model gets saved then update the view
       this.model.bind('sync', function(model, response, options) {
           var success = options.success;
           if (success) { this.reRender(); }
       }, this);

       // Rebind events when new elements get added to the grid.
       $(this.$el).delegate('.entry', 'mouseover', _.bind(function() {
          this.bindEvents.call(this);
       }, this));

    },

    events : {
        "click a.remove-entry"    : "removeOne",
        "click a.edit-entry"      : "editEntry",
        "click a.duplicate-entry" : "copyEntry",
        "dblclick"                : "editEntry"
    },

    // Cache the dom element here if possible
    element: function() {

        return this.$el.children('.entry');
    },

    copyEntry: function() {
        var newTiming = this.model.clone();

        var startTime = moment(this.findStartTime()).add('minutes', 1).format('YYYY-MM-DDTHH:mmz');
        newTiming.set('id', null);
        newTiming.set('started_at', startTime);
        newTiming.set('ended_at', moment(startTime).add('minutes', newTiming.get('duration_minutes') - 1)); //START + DURATION

        newTiming.save({}, {
            success: function() {
                window.Track.grid.collection.add(newTiming);
                var view = new track.view.Timing({ model: newTiming });
                view.render();
            }
        });

        return false;

    },

    removeOne: function(event) {

        var response = window.confirm("Are you sure you want to delete?");
        if (response == true)
        {
            this.model.destroy();
        }
        return false;
    },

    /**
     * Returns a new model that represents a lunch task
     * @return {object} Backbone.js model
     *
     */
    createLunchTask: function(start, end, user_id) {

        var lunch = new track.model.Timing();
        lunch.set('started_at', start);
        lunch.set('ended_at', end);
        lunch.set('user_id', user_id);
        return lunch;
    },

    getColumn: function(){

        return $('[data-column-date="' + this.model.startDate() + '"]');
    },

    getProjectFromModel: function(model) {

        if (model) {
            //  return model.project;
            var pid = model.get('project_id');
            return this.projects.get(pid);
        }
        return null;
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
     * Set the title of an entry to the models current title
     *
     */
    setTitle: function() {

        if(this.getProjectFromModel(this.model)){
            var title = this.getProjectFromModel(this.model).get('name');
            this.element().find('.project_title').html(title);
        }
    },

    /**
     * Sets the top offset for a timing element
     *
     */
    setPosition: function() {

        var offset = track.util.calculateOffset(this.model.get('started_at'));

        this.element().css('top', offset);
    },

    setHeight: function() {

         var h = track.util.entryHeight(this.model.get('started_at'),
                                        this.model.get('ended_at'));

         this.element().css('height', h);
    },

    setTask: function() {

         var task = this.getTask();
         this.element().find('.task_title').html(task);
    },

    // When a model gets updated in the editor or grid update dom
    reRender: function() {

        this.setColor();
        this.setTitle();
        this.setPosition();
        this.setHeight();
        this.setTask();
    },

    /*
     * Gets the color directly from the json on first load
     *
     */
    getColor: function(model) {

        var project, color="#ccc";

        if (!model.isNew()) {
            project = this.getProjectFromModel(model);
            try {
                color = project.get('color');
            // Force refresh as server took too long to respond
            } catch (e) {  }
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

        if ( this.model.get('task_id') ){

            var project = this.projects.get(this.model.get('project_id')),
                task_id = this.model.get('task_id'),
                tasks = project.get('tasks'),
                results = _.filter(tasks, function(t) {
                    return t.id == task_id;
                });

            task = results[0].name;

        } else {
            task = "No task";
        }
        return task;
    },

    /**
     * Appends element to the DOM
     *
     */
    addToGrid: function() {

        this.$el.html(this.template(
            { model   : this.model,
              project : this.projectName(),
              id      : this.model.id || 0,
              task    : this.getTask() }));

        $(this.getColumn()).prepend(this.el);
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

        if(this.model.isNew()){
            new track.view.Editor({ model: this.model,
                                    date: date,
                                    collection: this.model.get('temporary_collection') }, true);
        } else {
            new track.view.Editor({ model: this.model,
                                    date: date }, true);
        }
        return false;
    },

    render: function() {
        if (this.model.isNew()) {
            this.model.set('user_id', Track.user());
        }

        this.addToGrid();
        this.bindEvents();
        this.setColor();
        this.setPosition();
        this.setHeight();
        track.lib.onResize(this.element());
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
     * Makes a full date string from a time t format HH:mm '20:23'
     *
     */
    fullString: function(t, d) {

        var str = track.util.fullDate(t, d);
        return track.lib.timeWithoutZone(str);
    },

    /**
     * When a time entry is changed on the grid, update the model
     *
     * @param {jQuery event) event
     *
     */
    onMoveStop: function(event, el) {

        this.$el.find('.time_indicator').hide();

        track.lib.ensureSafePosition(this.$el, this);

        var topPosition = this.model.calculateGridPosition(event);

        var column      = $(el).parents('.day_container'),
            columnDate  = track.util.getColumnDate(column),
            startTime   = track.util.convertOffsetToTime(topPosition),
            height      = this.model.calculateHeight(event),
            endTime     = track.util.endTime(topPosition, (height + 1));

        this.model.set('started_at', this.fullString(startTime, columnDate));
        this.model.set('ended_at', this.fullString(endTime, columnDate));

        this.updateEditor(startTime, endTime);

        if(!this.model.isNew()){
            this.model.save(); // Update the model automatically
        }
    },

    showTip: function() {
        $('<p class="tooltip">Double click to edit</p>')
            .text('Testing')
            .appendTo('body')
            .show();
    },

    /**
     * When user drags and entry give a visual indication of the start time
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

    findStartTime: function() {

        var date = moment(this.model.get('started_at')).format("YYYY-MM-DD");
        var lastDayTiming = null;

        window.Track.grid.collection.each(function(model) {
            endTime = new Date(Date.parse(model.get('ended_at')));
            if(moment(endTime).format("YYYY-MM-DD") == moment(date).format("YYYY-MM-DD")) {
                lastDayTiming = model;
            }
        });

        return lastDayTiming.get('ended_at');
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

            var opts =
              { axis: "y",
                stop: function(event, ui) {
                    self.onMoveStop(event, this); },
                drag: function(event) { self.onDrag(event); },
                containment: "#inner_timing_grid",
                obstacle: parent.find('.entry').not(this.element()),
                preventCollision: true };

            $(this.element()).draggable(opts).resizable({
                handles: 'n, s',
                resize: _.bind(function(event, ui) {
                    track.lib.restrictSize(ui);
                    self.onDrag(event);
                    track.lib.onResize(this.element());
                }, this),
                stop: function(event) {
                    self.onMoveStop(event, this);
                }
            });
        }
    }
});

