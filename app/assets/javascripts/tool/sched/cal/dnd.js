
/*global _ sched */

sched.ns( 'cal.dnd' );

sched.cal.dnd.dummy = $( '<div></div>' ).addClass( 'dummy entry' );

/**
 * Handler for drag start, cache some data about element positions in
 * the dnd object for later use.
 *
 * @param Object dnd
 * @param jQuery calendar
 * @param jQuery.Event evt
 */
sched.cal.dnd.onDragStart = function( dnd, calendar, evt ) {

    var dummy = sched.cal.dnd.dummy;
    var source = $( evt.target );
    var rows = $( '.row-data', calendar );

    dnd.offsetY = $( '.entries', calendar ).offset().top - $( document ).scrollTop();
    dnd.rows = _.chain( rows )
                .map( sched.cal.util.toIncludeEntries )
                .value();

    source.trigger( 'movestart' );

    dummy.css({ width: source.width() });

};

/**
 * During drag we need to update the dummy with the entries new
 * position when it is dropped.
 *
 * @param Object dnd
 * @param jQuery calendar
 * @param jQuery.Event evt
 */
sched.cal.dnd.onDrag = function( dnd, calendar, evt ) {

    var pos = { top: evt.clientY - dnd.offsetY };
    var entry = sched.cal.util.toPositionInfo( evt.target );
    var row = sched.cal.util.rowFor( dnd.rows, pos );

    if ( !row ) { return; }

    entry.pos.left -= (entry.pos.left % sched.cal.pxCellWidth);
    entry.pos.top = sched.cal.util.topPositionFor( row, entry );

    sched.cal.dnd.dummy
        .remove()
        .appendTo( row.element )
        .data( 'row', row.element )
        .pos( entry.pos );

};

/**
 * On drag stop we can place the entry in the dummy position, move
 * it's row, and re-set it up.
 *
 * @param Object dnd
 * @param jQuery calendar
 * @param jQuery.Event evt
 */
sched.cal.dnd.onDragStop = function( dnd, calendar, evt ) {

    var dummy = sched.cal.dnd.dummy;
    var pos = dummy.position();
    var row = dummy.data( 'row' ) || dnd.rows[0].element;
    var entry = $( evt.target );
    var model = entry.data( 'model' );

    entry.remove()
         .pos( pos )
         .appendTo( row )
         .data( 'model', model );

    model.onChangePosition( calendar, entry );

    dummy.remove();

};

/**
 * On resize start add styling class for feedback
 *
 * @param Object dnd
 * @param jQuery calendar
 * @param jQuery.Event evt
 */
sched.cal.dnd.onResizeStart = function( dnd, calendar, evt ) {

    $( evt.target )
        .parent()
        .addClass( 'resizing' );

};

/**
 * On resize stop we need to shake down the entrys row
 *
 * @param Object dnd
 * @param jQuery calendar
 * @param jQuery.Event evt
 */
sched.cal.dnd.onResizeStop = function( dnd, calendar, evt ) {

    var entry = $( evt.target );
    var model = entry.data( 'model' );

    entry.parent().removeClass( 'resizing' );

    model.onChangePosition( calendar, entry );

};

