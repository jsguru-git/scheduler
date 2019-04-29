
/*global _ sched */

sched.ns( 'cal.editor' );

sched.cal.editor.offset = null;
sched.cal.editor.projects = [];
sched.cal.editor.clients = [];
sched.cal.editor.nibWidth = 220;
sched.cal.editor.nibHeight = 23;

/**
 * Click handler for adding a new entry
 *
 * @param jQuery calendar
 * @param jQuery.Event evt
 */
sched.cal.editor.onClick = function( calendar, evt ) {

    var pos = sched.cal.editor.posForClick( calendar, evt );
    var user_id = sched.cal.util.userIdFor(calendar,pos);
    var date = sched.cal.util.dateFor( calendar, pos );
    var entry = new sched.model.Entry({ start_date: date,
                                        end_date: date,
                                        user_id: user_id });

    var element = sched.cal.addEntry( calendar, entry )
        .resizable( 'disable' )
        .draggable( 'disable' )
        .addClass( 'adding' );

    sched.cal.editor.showFor( 
        calendar,
        entry,
        element,
        sched.cal.editor.positionStandard
    );

};

/**
 * Cancels any current create/edit.  This function is dynamically
 * rebound to cancel the current create/edit operation.
 *
 */
sched.cal.editor.cancel = function() {};

/**
 * Get the editor position relative to the specified element
 *
 * @param jQuery element
 *
 * @return Object
 */
sched.cal.editor.positionStandard = function( element ) {

    var offset = element.offset();
    var pxPopupWidth = 240;

    return { left: offset.left - (pxPopupWidth / 2) + (element.width() / 2),
             top: offset.top + element.height() + sched.cal.editor.nibHeight };

};

/**
 * Get the editor position using the click event
 *
 * @param jQuery.Event evt
 * @param jQuery element
 *
 * @return Object
 */
sched.cal.editor.positionClick = function( evt, element ) {

    var pos = sched.util.clientPosFor( evt );

    return _.extend(
        sched.cal.editor.positionStandard( element ),
        { left: pos.clientX - (sched.cal.editor.nibWidth / 2) }
    );

};

/**
 * Show the edit/create dialog for the entry with its element
 *
 * @param jQuery calendar
 * @param sched.model.Entry entry
 * @param jQuery element
 * @param Function positioner
 *
 * @todo refactor cancel/delete to backbone view
 */
sched.cal.editor.showFor = function( calendar, entry, element, positioner ) {
    var view = new sched.view.Editor({ projects: sched.cal.editor.projects,
                                       clients: sched.cal.editor.clients,
                                       model: entry,
                                       element: element,
                                       calendar: calendar });
    var popup = view.$el.appendTo( 'body' ).offset(positioner(element));



    sched.cal.editor.cancel();
    sched.cal.editor.cancel = _.bind( view.cancel, view );
};

/**
 * Get a project for the specified ID
 *
 * @param integer projectName
 *
 * @return String
 */
sched.cal.editor.projectFor = function( projectName ) {

    var toMatchingName = function( e ) {
        return sched.util.strlower( e.get('name') )
            == sched.util.strlower( projectName );
    };

    return _.chain( sched.cal.editor.projects )
            .filter( toMatchingName )
            .first()
            .value();

};

/**
 * Normalises the top/left positions of a click to be relative inside
 * the calendar element.
 *
 * @param jQuery calendar
 * @param jQuery.Event evt
 *
 * @return Object {left:X,top:Y}
 */
sched.cal.editor.posForClick = function( calendar, evt ) {

    var scroller = $( '.scroller', calendar );
    var pos = sched.util.clientPosFor( evt );

    return { left: pos.clientX + 
                   scroller.scrollLeft() - 
                   sched.cal.editor.offset.left,
             top: pos.clientY - 
                  sched.cal.editor.offset.top +
                  $( document ).scrollTop() };

};

/**
 * Add a project object to our list if we don't have it already
 *
 * @param Object project
 */
sched.cal.editor.addProject = function( data ) {

    var hasProject = _.find(
        sched.cal.editor.projects,
        function( p ) { return p.id == data.id; }
    );

    if ( !hasProject ) {
        var project = new sched.model.Project( data );
        sched.cal.editor.projects.push( project );
    }

};

/**
 * Refreshes the editor projects, then fires the callback on success
 *
 * @param Function callback
 */
sched.cal.editor.refreshProjects = function( callback ) {

    var projects = new sched.model.Projects();

    projects.fetch({ 
        success: function( res ) {
            sched.cal.editor.projects = res.models;
            callback();
        }
    });
};

/**
 * Refreshes the editor clients, then fires the callback on success
 *
 * @param Function callback
 */
sched.cal.editor.refreshClients = function( callback ) {
    var clients = new sched.model.Clients();

    clients.fetch({
        success: function( res ) {
            sched.cal.editor.clients = res.models;
            callback();
        }
    });

};

/**
 * Initialise the calendar editor that allows adding/editing entries
 *
 * @param jQuery calendar
 */
sched.cal.editor.init = function( calendar ) {

    if ( !calendar.can('edit-entries') ) { return; }

    var onClick = _.partial( sched.cal.editor.onClick, calendar );
    var scroller = $( '.scroller', calendar );
    var entries = $( '.row-data', calendar );

    sched.cal.editor.offset = { top: ( entries.offset() || {} ).top,
                                left: scroller.offset().left };

    sched.cal.editor.refreshProjects(function() {
        entries.touch( onClick ).click( onClick );
    });

};

