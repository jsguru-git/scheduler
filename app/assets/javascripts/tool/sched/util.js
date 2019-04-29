
/*global sched */

sched.ns( 'util' );

sched.util.byYPos = function( pos, row ) {

    return row.pos.top < pos.top;

};

sched.util.lowestFirst = function( a, b ) {

    return b.pos.top - a.pos.top;

};

sched.util.highestFirst = function( a, b ) {

    return a.pos.top - b.pos.top;

};

/**
 * Reducer, given elements with a position and height, reduce
 * to the maximum top position.
 *
 * @param integer acc
 * @param Object e
 *
 * @return integer
 */
sched.util.toMaxTop = function( acc, e ) {

    var top = e.pos.top + e.height;

    return top > acc
        ? top
        : acc;

};

/**
 * Function that does nothing and returns true
 *
 */
sched.util.noop = function() {

    return true;
    
};

/**
 * Lowercases a (possibly null or undefined) String
 *
 * @param String str
 *
 * @return String
 */
sched.util.strlower = function( str ) {

    return str ? str.toLowerCase() : '';

};

/**
 * Work out client X position for the event (could be desktop click
 * or mobile touch event)
 *
 * @param jQuery.Event evt
 *
 * @return Object
 */
sched.util.clientPosFor = function( evt ) {

    var pos = function( axis ) {
        var property = 'client' +axis;
        return evt.originalEvent.touches
            ? evt.originalEvent.touches[0][ property ]
            : evt[ property ];
    };

    return { clientX: pos('X'),
             clientY: pos('Y') };

};

