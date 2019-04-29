/*global _ sched Backbone moment JST main_notification */

sched.ns( 'view' );

sched.view.Editor = Backbone.View.extend({

    template: JST["tool/sched/templates/editor"],

    /**
    * Initialize the view with the options
    *
    * @param Object options
    */
    initialize: function( options ) {
        _.extend( this, options );

        this.offset = $('.calendar-editor').offset();
        this.filteredProjects = this.projects;
        this.recentProjects = new sched.collection.RecentProjects({ user_id: this.model.get('user_id') });

        this.exclude_non_working_days = 1;

        this.clients = new sched.model.Clients();
        this.selectedClient = "";

        this.filteredRecentProjects = this.recentProjects;
        this.recentProjects.fetch({
            success: _.bind(function(res) {
                this.filteredRecentProjects = _.clone(this.recentProjects);
                this.render();
            }, this)
        });

        this.clients.fetch({
            success: _.bind(function(res) {
                this.render();
            }, this)
        });
        this.render();

    },

    /**
    * Initialize event handlers
    *
    */
    initEvents: function() {
        $('.opportunity-dialog', this.el).hide();
        var view = this;
        var onCheckNewProject = _.bind( this.checkNewProject, this );
        $( '.create', this.el ).click( _.bind(this.onSaveClick,this) );
        $( '.delete', this.el ).click( _.bind(this.onDeleteClick,this) );
        $( '.cancel', this.el ).click( _.bind(this.onCancelClick,this) );
        $('.calendar-editor', this.el).draggable({
            stop: function() {
                view.offset = $('.calendar-editor').offset();
            }
        });

        $('.select2.clients', this.el).change(function() {

            view.selectedClient = $('.select2.clients').select2('val');

            if($('.select2.clients').select2('val') == "") {
                view.filteredProjects = view.projects;
            }
            else {
                view.filteredProjects = _.filter(view.projects, function(project) {
                    return project.get('client_id') == $('.select2.clients').select2('val');
                });
            }

            if($('.select2.clients').select2('val') != "") {
                view.filteredRecentProjects.reset();
            }
            else {
                view.filteredRecentProjects = view.recentProjects;
            }

            view.render();
        });

        $('.select2.projects', this.el).change(function() {
            var project = _.find(view.filteredProjects, function(project) {
                return project.get('name') == $('.select2.projects', this.el).select2('val');
            });
            if(project.get('project_status') == 'opportunity') {
                $('.opportunity-dialog', this.el).show();
                if(project.get('project_status_overridden')) {
                    project.set('project_status', 'scheduled');
                    project.set('project_status_overridden', true);
                    project.save();
                }
                $( '#opportunity', this.el).click( function() {
                    project.set('project_status', 'opportunity');
                    project.set('project_status_overridden', true);
                    project.save();
                });

            }else{
                $('.opportunity-dialog', this.el).hide();
            }
        });


        $( '.scroller', this.calendar )
        .scroll( _.bind(this.onScroll,this) );
    },

    events: {
        "change input[name=exclude_non_working_days]": "toggleExcludeNonWorkingDays"
    },

    toggleExcludeNonWorkingDays: function() {
        if (this.exclude_non_working_days == 0) {
            this.exclude_non_working_days = 1;
        } else {
            this.exclude_non_working_days = 0;
        }
    },

    /**
    * Indicates if the project is new or not
    *
    * @return boolean
    */
    isNewProject: function() {

        var name = this.projectName().toLowerCase();
        var names = _.chain( this.projects )
        .map( this.toSelectOption )
        .map( sched.util.strlower )
        .concat( [''] )
        .value();

        return ( _.indexOf( names, name ) == -1 );

    },

    /**
    * Sets appropriate class to indicate if a project will be created
    *
    */
    checkNewProject: function() {

        var toggler = this.isNewProject()
        ? 'addClass'
        : 'removeClass';

        this.el[ toggler ]( 'new-project' );

    },

    /**
* Handler for when a project is selected
    *
    */
    onProjectSelected: function() {

        this.el.removeClass( 'new-project' );

    },

    /**
    * Handler for cancelling an edit/create operation
    *
    */
    onCancelClick: function() {

        this.cancel();

    },

    /**
    * On calendar scroll hide the editor
    *
    */
    onScroll: function() {

        this.cancel();

    },

    /**
    * On date selector constrain other date field
    *
    * @param String field
    * @param String selector
    * @param String value
    */
    onDatePicked: function( field, selector, value ) {

        $( selector, this.el )
        .datepicker( 'option', field, value );

    },

    /**
    * Delete the model and hide the editor
    *
    */
    onDeleteClick: function() {

        var response = window.confirm("Are you sure you want to delete?");
        if (response == true)
            {
                this.model.destroy();
                this.cancel();
            }

        },

        /**
    * Handler for when save is clicked
        *
        */
        onSaveClick: function() {

            this.$el.addClass( 'saving-entry' );
            this.save();

        },

        /**
        * Cancels the editor
        *
        */
        cancel: function() {

            if ( this.element.hasClass('adding') ) {
                this.element.remove();
            }

            this.hide();

        },

        /**
        * Hide the editor
        *
        */
        hide: function() {
            this.remove();
        },

        /**
        * Save the values from the editor fields to the model
        *
        */
        save: function() {

            var view = this;
            var projectName = this.projectName();
            var clientId = this.clientId();
            var dateFormat = 'DD/MM/YYYY';
            var dateMoment = function( name ) {
                var date = moment( $( '.date-' +name, view.el ).val(),
                dateFormat );
                return date.format( sched.cal.DATE_FORMAT );
            };

            data = {
                entry: {
                    start_date: dateMoment('start'),
                    end_date: dateMoment('end'),
                    project_name: projectName,
                    user_id: this.model.get('user_id')
                },
                exclude_non_working_days: this.exclude_non_working_days
            }

            $.ajax({
                type: "POST",
                url: '/calendars/entries.json',
                data: data,
                success: function(resp) {
                    view.element.hide();
                    _.each(resp, function(x) {
                      var newEntry = new sched.model.Entry(x);
                      sched.cal.addEntry(view.calendar, newEntry);
                    });
                    view.hide();
                },
                error: function(resp) {
                    $( '.errors ul', view.el ).html('');
                    var fields = { start_date: 'Start date',
                                   end_date: 'End date',
                                   project_id: 'Project' };

                    var total = 0;

                    _.each( $.parseJSON(resp.responseText), function(message) {
                        for(var k in message) {
                            total++;
                            $( '.errors ul', view.el ).append('<li>' + fields[k] + ' ' + message[k] + '</li>');
                        }
                    });

                    $('.info',  view.el).html( total+ ' error' +(total==1?'':'s')+ ' occurred:' );
                    view.$el.removeClass( 'saving-entry' ).addClass( 'has-errors' );
                }
            });

        },

        /**
        * Return current project name
        *
        * @return String
        */
        projectName: function() {

            return $( '.projects option:selected', this.el )
            .val()
            .trim();

        },

        /**
        * Return current client selected
        *
        * @return Integer
        */
        clientId: function() {

            return $( '.clients option:selected', this.el )
            .val()
            .trim();

        },

        /**
        * Maps project models to just their name
        *
        * @param sched.model.Project project
        *
        * @return String
        */
        toSelectOption: function( project ) {

            return project.get( 'name' );

        },

        /**
        * Initilizes date views
        */
        initDateViews: function() {
            var firstDay = 1;
            var dateFormat = 'DD/MM/YYYY';
            var datePickerFormat = 'dd/mm/yy';
            var startDate = this.model.moment('start_date').format(dateFormat);
            var endDate = this.model.moment('end_date').format(dateFormat);

            $( '.date-start', this.el )
            .val( startDate )
            .datepicker({
                dateFormat: datePickerFormat,
                firstDay: firstDay
            });

            $( '.date-end', this.el )
            .val( endDate )
            .datepicker({
                dateFormat: datePickerFormat,
                firstDay: firstDay
            });
        },

        /**
        * Initialize selector views
        */
        initSelectViews: function() {
            $('.select2.projects', this.$el).select2();
            $('.select2.clients', this.$el).select2({
                placeholder: 'Select a Client',
                allowClear: true
            });
            $('.select2.clients', this.$el).select2('val', this.selectedClient);
            if(this.model.get('project')) {
                $('.select2.projects', this.$el).select2('val', this.model.get('project').name);
            }
        },

        /**
        * Render editor into el
        *
        */
        render: function() {
            this.$el.html(this.template());
            this.initSelectViews();
            this.initDateViews();
            this.initEvents();
            $('.calendar-editor').offset(this.offset);
        }

    });
