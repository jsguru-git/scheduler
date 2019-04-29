/*global _ track Backbone JST Track moment log alert hopscotch */

/*
 * The editor window is a light box that lets you edit or create an entry
 * View must be instantiated with an associated model
 *
 */
track.ns( 'view' );

track.view.Editor = Backbone.View.extend({

    LOADER: '.submit-loader',

    editorTpl: JST["tool/track/templates/editor"],

    /**
     * @param options {object}
     *
     */
    initialize: function(options) {

        _.extend(this,options);

        var onLoad = _.bind(
            this.onProjectsLoaded,
            this
        );

        Track.fetchProjects(onLoad);
        if (hopscotch.getCurrTour() != null) {
            hopscotch.showStep(1);
        }
    },

    /**
     * When projects are loaded we can show the editor
     *
     * @param projects {track.collection.Project}
     */
    onProjectsLoaded: function(projects) {

        this.projects = projects;

        this.render();
        this.hideLoadingDiv();
    },

    events: {
        'submit #time-edit'    : 'saveModel',
        'click .cancel'        : 'hide'
    },

    hideLoadingDiv: function() {

      $('#loading').hide();
    },

    render: function() {

        var notArchived = function(project) {
            return !project.get('archived') && project.get('project_status') != 'closed' ;
        };

        $('.time-editor').remove(); // clear out old windows

        var start = this.model.get('started_at'),
            end   = this.model.get('ended_at'),
            tpl   = this.editorTpl({model: this.model,
                                    projects: this.projects.models.filter(notArchived)});
 
        var container = this.$el
            .html(tpl);

        $("#track_calendar")
            .append(container);

        $('.time-editor', container)
            .data('editor', this);

        this.setPosition();
        this.bindEvents();

        var s = track.lib.hmFromString(start),
            e = track.lib.hmFromString(end);

        this.setStartTime.apply(this, s);
        this.setEndTime.apply(this, e);

        this.initSelectBoxes();
    },

    /**
     * Initialize any select boxes that need it
     *
     */
    initSelectBoxes: function() {

        var config = {
            width: 'off',
            matcher: this.optGroupMatcher()
        };

        $('.select2', this.el)
            .not('.select2-offscreen')
            .select2(config);
    },

    /**
     * Allow search by option group labels too.
     *
     */
    optGroupMatcher: function() {
        return function(term, optText, els) {

            var allText = optText + els[0].parentNode.getAttribute('label')  || '';

            return (''+allText).toUpperCase().indexOf((''+term).toUpperCase()) >= 0;
        };
    },

    /**
     * Sets the top and left offset for the editor modal overlay
     *
     */
    setPosition: function() {


        try { // Catch IE exception

            var el = $("[data-model='" + this.model.cid + "']");
            var cal = $('#track_calendar');
            var editor = $('.time-editor', cal);
            var editorWidth = editor.width();
            var calWidth = cal.width();
            var calTop = cal.scrollTop();
            var padding = calWidth * 0.05;
            var elLeft = el.offset().left - cal.offset().left;
            var elWidth = el.width();
            var topPos = calTop + padding;
            var leftPos = (elLeft + elWidth + editorWidth + padding) > calWidth
                ? elLeft - editorWidth - padding
                : elLeft + elWidth + padding;

            editor.css({ 'left': leftPos,
                         'top': topPos });

        } catch (e) { return; }
    },

    /**
     * @param {string} s name of class i.e '.to_field'
     *
     */
    getTime: function(s) {

        var hours = $(s + ' .hour_select').val();
        var mins = $(s + ' .minute_select').val();

        return [hours, mins].join(':');
    },

    disableTaskSelection: function() {
        $('.task-options').html('');
    },

    // Getters

    getStartTime: function () {

        return this.getTime('.from_field');
    },

    getEndTime: function () {

        return this.getTime('.to_field');
    },

    // Setters

    setStartTime: function(hours, minutes) {

        if (hours < 10) { hours = '0' + hours; }
        if (minutes < 10) { minutes = '0' + minutes; }
        $('.from_field .hour_select').val(hours.toString());
        $('.from_field .minute_select').val(minutes.toString());
    },

    setEndTime: function(hours, minutes) {

        if (hours < 10) { hours = '0' + hours; }
        if (minutes < 10) { minutes = '0' + minutes; }
        $('.to_field .hour_select').val(hours.toString());
        $('.to_field .minute_select').val(minutes.toString());
    },

    /**
     * Concatenates the date and the time fields
     * and returns a new Date object
     *
     * @param {string} time string with format HH:mm
     *
     */
    makeFullDateString: function(time) {

        return track.util.fullDate(time, this.model.startDate());
    },

    startedAt: function() {

        var time = this.getStartTime();

        return track.util.fullDate(time, this.model.startDate());
    },

    endedAt: function() {

        var time = this.getEndTime();

        return track.util.fullDate(time, this.model.startDate());
    },

    getProjectId: function() {

        var data = $('.project', this.el)
            .select2('data');

        return data
            ? $(data.element).data('projectid')
            : null;
    },

    /**
     * Returns information from the editor window notes field
     *
     * @return {string}
     *
     */
    getNotes: function() {

        return $('.notes').val().trim();
    },

    /**
     * Return the task id value from the editor window.
     * This can be null which is fine as it just sets the task_id to null
     *
     */
    getTaskId: function() {

        return $('.project', this.el)
            .select2('val');
    },

    /**
     * Given a project id, will return all tasks for a project
     * TODO document.createDocumentFragment for faster inject?
     *
     * @param {number} project_id
     *
     */
    getTasks: function(project_id, callback_fn) {

        this.disableTaskSelection();

        var tasks = new track.collection.Tasks({user_id: Track.user(),
                                                project_id: project_id});

        var model_id = this.model.get('task_id');

        tasks.fetch({success: function() {

            $('.task-options').empty();
            var template = '<option value="" disabled="disabled">Select your task</option>';
            $('.task-options').append(template);
            _.each(tasks.models, _.bind(function(task){
                var selected = (function() {
                    return task.get('id') == model_id ?
                        'selected="selected"' : '';
                }());
                var opt = '<option value="' +
                           task.get('id') +
                           '"' +
                           selected +
                           '>' +
                           task.get('name') +
                           '</option>';
                $('.task-options').append(opt);

            }, this));
            if (callback_fn) { callback_fn.call(this); } // Run callback if it exists
        }});
    },

    /**
     *
     * @param {number} id
     * @param {number} project_id
     *
     */
    getTaskById: function(id, project_id) {

        var tasks = new track.collection.Tasks({user_id: Track.user(),
                                                project_id:project_id });
        tasks.fetch({success: _.bind(function() {
           return tasks.get(id).get('name');
        }, this)});
    },

    /**
     * Editor submit button clicked
     *
     */
    saveModel: function(event) {

        event.preventDefault();

        this.model.clearErrors();

        // Check the inputs to make sure there are no errors
        this.model.unset("temporary_collection");

        this.model.set("started_at", track.lib.timeWithoutZone(this.startedAt()));
        this.model.set("ended_at", track.lib.timeWithoutZone(this.endedAt()));
        this.model.set("project_id", this.getProjectId());
        this.model.set("notes", this.getNotes());
        this.model.set("task_id", this.getTaskId());

        $(this.LOADER).show(); // Show a loading div

        if (this.collection) {
            // Should use merge:true from backbone js v0.9.9
            this.collection.add(this.model);
        } else {
            this.model.save();
        }
        if(hopscotch.getCurrTour() != null) {
            hopscotch.showStep(5);
        }
    },

    hide: function(event) {

        this.$el.remove();
        if (this.model.isNew()) {
            this.model.destroy();
        }
        if(hopscotch.getCurrTour() != null) {
            hopscotch.endTour();
        }
        return false;
    },

    /**
     * Prevent the editor window escaping the screen
     * Collision detection
     *
     * @param {object} ui jQuery ui object
     *
     */
    onDrag: function(event, ui) {

        var boundRight = parseInt($('#timing_grid').width(), 10) - 302,
            yOffset = $('#inner_timing_grid').position().top;

        if ((ui.position.top - yOffset) <= 0) {
            ui.position.top = 0;
        }

        if (ui.position.left <= 0) {
            ui.position.left  = 0;
        }

        if (ui.position.left>= boundRight) {
            ui.position.left = boundRight;
        }
    },

    getDataAttr: function(attr) {

        return $('#track_calendar_container').data(attr);
    },

    /**
     * Extracts the common project id from the DOM
     *
     * @return [number] the common project id
     */
    getCommonProjectId: function() {

        var attr =  this.getDataAttr('commonprojectid');
        return parseInt(attr, 10);
    },

    /**
     * Get the common tasks project info
     * from HTML5 data attributes in the DOM
     *
     * @return {object}
     */
    getCommonAttributes: function() {

        return {
            project_id: this.getDataAttr('commonprojectid'),
            link_break: this.getDataAttr('taskbreakid'),
            link_lunch: this.getDataAttr('tasklunchid'),
            link_leave: this.getDataAttr('taskannualleaveid'),
            link_absence: this.getDataAttr('taskflexileaveid'),
            link_sick: this.getDataAttr('tasksickleaveid')
        };
    },

    /**
     * Bind events on the editor icons
     *
     */
    bindIconEvents: function() {

        var attributes = this.getCommonAttributes();

        $('#quick_links a').bind('click', $.proxy(function(event) {
            var target = event.currentTarget.getAttribute('id');
            var taskId   = attributes[target];

            this.setTaskById(taskId);

            return false;
        }, this));
    },

    /**
     * Select a task by ID
     *
     * @param id {integer}
     */
    setTaskById: function(id) {

        $('.project', this.el)
            .select2('val', id);
    },

    /**
     * Bind common events
     *
     */
    bindEvents: function() {

        this.bindIconEvents();

        if (!Track.iPad()) { // Disable drag on iPad
            $('.time-editor').draggable({drag: _.bind(function(e, ui) {
                this.onDrag(e, ui);
            }, this)});
        }
    }
});

