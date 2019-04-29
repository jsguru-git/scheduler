
/*global _ sched */

sched.ns( 'cal.util' );

/**
 * Convert an entry to an object including its position and dimensions
 *
 * @param DOMElement e
 */
sched.cal.util.toPositionInfo = function( e ) {

    var item = $( e );

    return { element: item, 
             pos: item.position(),
             width: item.width(),
             height: item.height() };

};

/**
 *  Take a row element, and convert it to an object with its information
 *  and also its entries (not including source)
 *
 *  @param DOMElement e
 */
sched.cal.util.toIncludeEntries = function( e ) {

    var row = $( e );
    var elements = $( '.entry', row );
    var entries = _.chain( elements )
                   .map( sched.cal.util.toPositionInfo )
                   .value();

    return { element: row,
             pos: row.position(),
             entries: entries };

};

/**
 *  Filter method for finding colliding entries
 *
 *  @param Object entry
 *  @param Object other
 *
 *  @return boolean
 */
sched.cal.util.toColliding = function( entry, other ) {

    if ( entry.element.get(0) == other.element.get(0) ) {
        return false;
    }

    var makeBox = function( e ) {
        return { left: Math.floor(e.pos.left),
                 right: Math.floor(e.pos.left + e.width) };
    };

    var intersects = function( a, b ) {
        return ( a.left == b.left && a.right == b.right )
            || ( a.left > b.left && a.left < b.right )
            || ( a.right > b.left && a.right < b.right );
    };

    var box1 = makeBox( entry );
    var box2 = makeBox( other );

    return intersects( box1, box2 )
        || intersects( box2, box1 );

};

/**
 *  Finds the row in the row data matching current position
 *  
 *  @param Array rows Row data
 *  @param Object pos top/left position
 *
 *  @return Object row data
 */
sched.cal.util.rowFor = function( rows, pos ) {

    return _.chain( rows )
            .filter( _.partial(sched.util.byYPos,pos) )
            .sort( sched.util.lowestFirst )
            .first()
            .value();

};

/**
 *  Finds top position in the row for an object with given left offset
 *  and width.
 *
 *  @param Object row Row data object with entries
 *  @param Object entry
 *
 *  @return integer
 */
sched.cal.util.topPositionFor = function( row, entry ) {

    var pxTop = 0;
    var colliders = _.chain( row.entries )
                     .filter( _.partial(sched.cal.util.toColliding,entry) )
                     .value();

    var toTopColliders = function( e ) {
        return e.pos.top == pxTop;
    };

    while ( pxTop < 1000 ) { // safer than while(true)
        if ( _.filter(colliders,toTopColliders).length == 0 ) { break; }
        pxTop += (sched.cal.pxEntryHeight + 1);
    }

    return pxTop;

};

/**
 * Place an entry object in the specified row object
 *
 * @param Object row Object with position/entries
 * @param Object entry Object with position
 * @param Function placer Function to place an element ($.fn.css/$.fn.animate)
 */
sched.cal.util.placeEntryInRow = function( row, entry, placer ) {

    entry.pos.top = sched.cal.util.topPositionFor( row, entry );

    ( placer || $.fn.animate ).apply(
        entry.element,
        [{ top: entry.pos.top + 'px' }]
    );

};

/**
 * Shake down all rows in the calendar
 *
 * @param jQuery calendar
 */
sched.cal.util.shakeDown = function( calendar ) {

    var rowAdjuster = _.partial( sched.cal.util.adjustRowHeight, calendar );
    var elements = $( '.row-data', calendar );
    var rows = _.chain( elements )
                .map( sched.cal.util.toIncludeEntries )
                .value();

    _.each( rows, rowAdjuster );
    _.each( rows, sched.cal.util.shakeDownRow );

};

/**
 * Shake down all entries in a row
 *
 * @param Object row
 */
sched.cal.util.shakeDownRow = function( row ) {

    _.chain( row.entries )
     .sort( sched.util.highestFirst )
     .each(function( entry ) {
        sched.cal.util.placeEntryInRow( row, entry );
     });

};

/**
 * Adjust row height to make sure there's space for more entries
 *
 * @param jQuery calendar
 * @param Object row
 */
sched.cal.util.adjustRowHeight = function( calendar, row ) {

    var userId = row.element.data( 'userid' );
    var pxMinHeight = 70;
    var pxPadding = 25;
    var pxHeight = _.chain( row.entries )
                    .reduce( sched.util.toMaxTop, 0 )
                    .value() + pxPadding;

    row.height = pxHeight > pxMinHeight 
        ? pxHeight 
        : pxMinHeight;

    $( '.user-' +userId+ ', .data-user-' +userId, calendar )
        .animate({ height: row.height + 'px' });

};

/**
 * Indicates if the entry occurs after the start date
 *
 * @param Moment startDate
 * @param sched.model.Entry entry
 *
 * @return boolean
 */
sched.cal.util.startsAfter = function( startDate, entry ) {

    return entry.moment( 'start_date' )
                .diff( startDate ) > 0;

};

/**
 * Indicates of the entry ends before the specified date
 *
 * @param Moment endDate
 * @param sched.model.Entry entry
 *
 * @return boolean
 */
sched.cal.util.endsBefore = function( endDate, entry ) {

    return entry.moment( 'end_date' )
                .diff( endDate ) < 0;

};

/**
 * Work out the current left position for the specified date
 *
 * @param jQuery calendar
 * @param Moment date
 *
 * @return integer
 */
sched.cal.util.pxLeftForDate = function( calendar, date ) {

    var selector = '.row-date .col:first-child';
    var firstDate = $( selector, calendar ).moment();

    return date.diff( firstDate, 'days' ) * sched.cal.pxCellWidth;

};

/**
 * Finds the date for the specified position in the calendar
 *
 * @param jQuery calendar
 * @param Object pos
 */
sched.cal.util.dateFor = function( calendar, pos ) {

    var index = Math.floor( (pos.left+1) / sched.cal.pxCellWidth );
    var item = $( '.row-date .col', calendar ).get( index );

    return $( item ).data( 'date' );

};

/**
 * Given a top position (including the date bar) determine which user
 * row it is in.
 *
 * @param jQuery calendar
 * @param Object position
 *
 * @return integer
 */
sched.cal.util.userIdFor = function( calendar, pos ) {

    var users = $( '.user', calendar );

    return _.chain( users )
            .map( sched.cal.util.toPositionInfo )
            .filter( _.partial(sched.util.byYPos,pos) )
            .sort( sched.util.lowestFirst )
            .first()
            .value()
            .element
            .data( 'userid' );

};

