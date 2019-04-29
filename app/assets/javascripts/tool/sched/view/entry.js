
/*global _ sched Backbone */

sched.ns( 'view' );

sched.view.Entry = Backbone.View.extend({

    template: _.template( 
        '<div class="entry" ' +
            '<% if ( entry.get(\'project\') ) { %>' +
                'title="<%= entry.get(\'project\').name %>" ' +
            '<% } %>' +
            'style="' +
                '<% if ( entry.get(\'project\') ) { %>' +
                    'background-color:<%= entry.get(\'project\').color %>;' +
                    '<% if ( entry.get(\'project\').project_status == "opportunity" ) { %>' +
                        ' opacity: 0.6;' +
                    '<% } %>' +
                '<% } %>' +
             '">' +
            '<span class="label">' +
                '<% if ( entry.get(\'project\') ) { %>' +
                    '<%= entry.get(\'project\').name %>' +
                '<% } %>' +
            '</span>' +
        '</div>'
    ),

    /**
     * Initialize the entry view
     *
     * @param Object options
     */
    initialize: function( options ) {

        this.calendar = options.calendar;
        this.row = options.row;

        this.model.bind( 'sync', this.onModelChanged, this );
        this.model.bind( 'rowChanged', this.onRowChanged, this );
        this.model.bind( 'destroy', this.onDestroy, this );

        this.render();

    },

    /**
     * Render the entry in its initial row
     *
     */
    render: function() {

        var html = this.template({ entry: this.model });

        this.el = $( html )
            .appendTo( this.row )
            .data( 'model', this.model );

        this.initEvents();
        this.updatePosition( $.fn.css );

    },

    /**
     * Initialise, or re-initialise events on the entry element (may have
     * been removed from DOM and need events re-applying)
     *
     */
    initEvents: function() {

        var calendar = this.calendar;
        var dnd = {};

        var handler = function( func ) {
            return _.partial( func, dnd, calendar );
        };

        var dragConfig = {
            start: handler( sched.cal.dnd.onDragStart ),
            drag: handler( sched.cal.dnd.onDrag ),
            stop: handler( sched.cal.dnd.onDragStop ),
            containment: '.scroller'
        };

        var resizeConfig = {
            start: handler( sched.cal.dnd.onResizeStart ),
            stop: handler( sched.cal.dnd.onResizeStop ),
            handles: 'e,w',
            grid: [ sched.cal.pxCellWidth, 0 ],
            minWidth: sched.cal.pxCellWidth
        };

        var onDblClick = _.bind( this.onDblClick, this );

        if ( calendar.can('edit-entries') ) {
            this.el.bind( 'touchstart', onDblClick )
                   .click( onDblClick )
                   .draggable( dragConfig )
                   .resizable( resizeConfig );
        }

    },

    /**
     *
     * @param jQuery.Event evt
     */
    onDblClick: function( evt ) {

        evt.stopPropagation();
        evt.preventDefault();

        sched.cal.editor.showFor( 
            this.calendar,
            this.model,
            this.el,
            _.partial( sched.cal.editor.positionClick, evt )
        );

    },

    /**
     * Handler for when the models row has changed
     *
     */
    onRowChanged: function() {

        this.initEvents();

    },

    /**
     * The model has been deleted
     *
     */
    onDestroy: function() {

        this.el.remove();

    },

    /**
     * The model has changed, update the view
     *
     */
    onModelChanged: function() {

        var projectName = this.model.get( 'project_name' );
        var project = sched.cal.editor.projectFor( projectName );

        if ( project ) {
            this.el.css({ backgroundColor: project.get('color') });
        }

        this.el.removeClass( 'adding' )
               .resizable( 'enable' )
               .draggable( 'enable' )
               .find( 'span' )
               .html( projectName );

        this.updatePosition(
            $.fn.animate,
            _.partial( sched.cal.util.shakeDown, this.calendar )
        );
        if ( this.model.get('project').project_status == 'opportunity' ) {
            this.el.css('opacity', '0.6');
        }
    },

    /**
     * Update the entries position in its current row
     *
     * @param Function placer $.fn.css|$.fn.animate
     * @param Function callback
     */
    updatePosition: function( placer, callback ) {

        placer = placer || $.fn.animate;

        var start = this.model.moment( 'start_date' );
        var end = this.model.moment( 'end_date' );
        var pxLeft = sched.cal.util.pxLeftForDate( this.calendar, start );
        var pxWidth = (end.diff(start,'days') + 1) * sched.cal.pxCellWidth;
        var properties = { left: pxLeft + 'px',
                           width: pxWidth + 'px' };

        var onSuccess = _.bind(function() {
            var pxTop = sched.cal.util.topPositionFor(
                sched.cal.util.toIncludeEntries( this.el.parent() ),
                sched.cal.util.toPositionInfo( this.el )
            );
            placer.call( this.el, { top: pxTop + 'px' } );
            if ( callback ) {
                callback();
            }
        }, this);

        placer.apply( this.el,
                      [ properties, 'fast', null, onSuccess ]);

        if ( placer != $.fn.animate ) { onSuccess(); }

    }

});

