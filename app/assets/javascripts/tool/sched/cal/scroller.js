
/*global _ sched */

sched.ns( 'cal.scroller' );

sched.cal.scroller.pxTotal = null;
sched.cal.scroller.pxWidth = null;
sched.cal.scroller.pxLabelInset = 25;
sched.cal.scroller.isLoading = false;
sched.cal.scroller.clsFixed = 'label-fixed';
sched.cal.scroller.pxLabelPad = 5;
sched.cal.scroller.daysToReload = 14;

sched.cal.scroller.loadLeft = function( calendar ) {

    // @not implemented

};

/**
 * Load one more week to the right of the calendar
 *
 * @param integer pxDiff The new space difference to load
 * @param jQuery calendar
 */
sched.cal.scroller.loadRight = function( pxDiff, calendar ) {

    if ( sched.cal.scroller.isLoading ) { return; }

    var startDate = calendar.moment( 'enddate' );
    var daysToReload = Math.max(
        sched.cal.scroller.daysToReload,
        Math.ceil( pxDiff / sched.cal.pxCellWidth ) + sched.cal.scroller.daysToReload
    );
    var endDate = startDate.clone().add( 'days', daysToReload );

    sched.cal.scroller.isLoading = true;
    calendar.moment( 'enddate', endDate );

    sched.cal.loadEntries({
        calendar: calendar, 
        startDate: startDate, 
        endDate: endDate, 
        filter: _.partial( sched.cal.util.startsAfter, startDate ),
        callback: function() {
            sched.cal.scroller.isLoading = false;
        }
    });

};

/**
 * Handler for when scrolling starts we pre-compute a bunch of data we'll
 * need when checking scroll positions for various things.
 *
 * @param Object dnd
 * @param jQuery calendar
 */
sched.cal.scroller.onScrollStart = function( dnd, calendar ) {

    dnd.containers = sched.cal.scroller.containersFor( calendar );

};

/**
 * Returns all the containers with info needed during scroll to compute
 * offsets and stuff.
 *
 * @param jQuery calendar
 *
 * @return Array
 */
sched.cal.scroller.containersFor = function( calendar ) {

    var elements = $( '.entry, .month', calendar );

    var withLabel = function( container ) {
        return _.extend( container, {
            label: $( '.label', container.element )
        });
    };

    var withLeftRightLimits = function( container ) {
        return _.extend( container, {
            leftMin: container.pos.left - sched.cal.scroller.pxLabelPad,
            rightMax: container.pos.left + 
                      container.width - 
                      container.label.width() - 
                      (sched.cal.scroller.pxLabelInset * 2) 
        });
    };

    return _.chain( elements )
            .map( sched.cal.util.toPositionInfo )
            .map( withLabel )
            .map( withLeftRightLimits )
            .value();

};

/**
 * On scroll check if we need to load more containers to the left/right
 *
 * @param Object dnd
 * @param jQuery calendar
 * @param jQuery.Event evt
 */
sched.cal.scroller.checkInfiniteScroll = function( dnd, calendar, evt ) {

    var loader = null;
    var pxLeft = $( evt.target ).scrollLeft();
    var leftMin = sched.cal.FOUR_DAYS;
    var rightMax = sched.cal.scroller.pxTotal
        - sched.cal.scroller.pxWidth
        - sched.cal.FOUR_DAYS;

    if ( pxLeft > rightMax ) {
        loader = _.partial(
            sched.cal.scroller.loadRight,
            pxLeft - rightMax
        );
    }

    if ( loader ) {
        loader( calendar );
    }

};

/**
 * On scroll check if entry labels need their position fixing
 *
 * @param Object dnd
 * @param jQuery calendar
 * @param jQuery.Event evt
 */
sched.cal.scroller.checkContainerLabels = function( dnd, calendar, evt ) {

    sched.cal.scroller.positionLabelsFor(
        dnd.containers,
        $( evt.target )
    );

};

/**
 * Check all the labels for the containers in the specified scroller
 *
 * @param Array containers (Created with containersFor())
 * @param jQuery scroller
 */
sched.cal.scroller.positionLabelsFor = function( containers, scroller ) {

    var pxLeft = scroller.scrollLeft() - sched.cal.scroller.pxLabelInset;

    var shouldFixLabelFor = function( entry ) {
        return pxLeft > entry.leftMin 
            && pxLeft < entry.rightMax;
    };

    var checkPosition = function( entry ) {
        if ( shouldFixLabelFor(entry) ) {
            entry.label.addClass( sched.cal.scroller.clsFixed )
                       .pos({ top: 1, left: pxLeft - entry.pos.left + sched.cal.scroller.pxLabelPad });
        }
        else {
            sched.cal.scroller.resetContainer( entry.label );
        }
    };

    _.each( containers, checkPosition );

};

/**
 * Resets a containers label to be normally positioned
 *
 * @param jQuery label
 */
sched.cal.scroller.resetContainer = function( label ) {

    label.removeClass( sched.cal.scroller.clsFixed );

};

/**
 * We need to reset label positions when entries are moved
 *
 * @param jQuery.Event evt
 */
sched.cal.scroller.onEntryMove = function( evt ) {

    var label = $( '.label', evt.target );

    sched.cal.scroller.resetContainer( label );

};

/**
 * Initialise (or reinitialise) all rows in a calendar
 *
 * @param jQuery calendar
 */
sched.cal.scroller.initRows = function( calendar ) {

    var numDays = $( '.row-date .col' ).length;

    sched.cal.scroller.pxTotal = numDays * sched.cal.pxCellWidth;

    $( '.row', calendar )
        .css({ width: sched.cal.scroller.pxTotal + 'px' });

};

/**
 * Initialise the calendar scroller
 *
 * @param jQuery calendar
 */
sched.cal.scroller.init = function( calendar ) {

    var dnd = {};
    var scroller = $( '.scroller', calendar );
    var handler = function( name ) {
        return _.partial( sched.cal.scroller[name], dnd, calendar );
    };

    scroller.scrollLeft( sched.cal.ONE_WEEK );

    $( '.entry', scroller )
        .bind( 'movestart', sched.cal.scroller.onEntryMove );

    sched.cal.scroller.pxWidth = scroller.width();
    sched.cal.scroller.initRows( calendar );
    sched.cal.scroller.positionLabelsFor(
        sched.cal.scroller.containersFor( calendar ),
        scroller
    );

    scroller.bind( 'scroll', handler('checkContainerLabels') )
            .bind( 'scroll', handler('checkInfiniteScroll') )
            .bind( 'scrollstart', handler('onScrollStart') );

};

