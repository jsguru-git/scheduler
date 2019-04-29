
/*global _ sched */

sched.ns( 'cal' );

sched.cal.pxCellWidth = 60;
sched.cal.pxEntryHeight = 18;
sched.cal.DATE_FORMAT = 'YYYY-MM-DD';
sched.cal.ONE_WEEK = sched.cal.pxCellWidth * 7;
sched.cal.FOUR_DAYS = sched.cal.pxCellWidth * 4;

/**
 * Initialise the range of date values
 *
 * @param jQuery calendar
 * @param Moment startDate
 * @param Moment endDate
 */
sched.cal.initDates = function( calendar, startDate, endDate ) {

    var format = sched.cal.DATE_FORMAT;
    var currDate = startDate.clone();
    var row = $( '.row-date', calendar );
    var days = [];

    while ( currDate.format(format) != endDate.format(format) ) {
        var date = sched.tpl.date({ num: currDate.format( 'Do' ),
                                    word: currDate.format( 'ddd' ),
                                    date: currDate.format( format ),
                                    month: currDate.format( 'MMMM' ) });
        currDate.add( 'days', 1 );
        row.append( date );
    }

};

/**
 * Add the users down the left side and the data rows for them
 *
 * @param jQuery calendar
 * @param Array users
 */
sched.cal.initUsers = function( calendar, users ) {

    var entries = $( '.entries', calendar );
    var html = sched.tpl.users({ users:users });
    var startDate = calendar.moment( 'startdate' );
    var initUser = _.partial(
        sched.cal.initUser,
        startDate.day(),
        entries
    );

    $( '.users', calendar )
        .append( html );

    _.each( users, initUser );
    
};

/**
 * Initialise a user row in the entries element
 *
 * @param int dayOfWeek
 * @param jQuery entries
 * @param sched.cal.model.User user
 */
sched.cal.initUser = function( dayOfWeek, entries, user ) {

    var html = sched.tpl.data({ user:user, dayOfWeek:dayOfWeek });
    var element = $( html );

    entries.append( element );

};

/**
 * Add an entry to the calendar, initialize and position it.
 *
 * @param jQuery calendar
 * @param Entry entry backbone model
 */
sched.cal.addEntry = function( calendar, entry ) {

    var userId = entry.get( 'user_id' );
    var row = $( '.data-user-' +userId, calendar );
    var view = new sched.view.Entry({ calendar: calendar,
                                      row: row,
                                      model: entry });

    return view.el;

};

/**
 * Initialise a period of time in the calendar and add the specified
 * entries to the calendar.
 *
 * @param Object options Object literal of options:
 *
 * jQuery calendar
 * Moment startDate
 * Moment endDate
 * Array entries
 */
sched.cal.initPeriod = function( options ) {

    var addToCalendar = _.partial( sched.cal.addEntry, options.calendar );

    sched.cal.initDates( 
        options.calendar,
        options.startDate,
        options.endDate
    );

    _.each( options.entries, addToCalendar );

    sched.cal.scroller.initRows( options.calendar );

};

/**
 * Loads entries that occur between the start and end dates, and then
 * passes them to the callback.
 *
 * @param Object options Object literal of options:
 *
 * calendar jQuery
 * startDate Moment
 * endDate Moment
 * filter Function Filter for entries after load
 * callback Function
 */
sched.cal.loadEntries = function( options ) {

    var callback = options.callback || sched.util.noop;
    var filter = options.filter || sched.util.noop;
    var entries = new sched.model.Entries( [], { startDate: options.startDate,
                                                 endDate: options.endDate,
                                                 projectId: options.calendar.data('projectid') });

    entries.fetch({
        success: function( res ) {
            options.entries = _.chain( res.models )
                               .filter( filter )
                               .value();
            sched.cal.initPeriod( options );
            callback();
        }
    });

};

/**
 * Fetch a user by id
 *
 * @param jQuery calendar
 * @param Function callback
 */
sched.cal.userFetcher = function( calendar, callback ) {

    var user = new sched.model.User({ 
        id: calendar.data('userid') 
    });

    user.fetch({
        success: function( model ) {
            callback( [model] );
        }
    });

};

/**
 * Fetch many users, possibly filtered by project or team
 *
 * @param jQuery calendar
 * @param Function callback
 */
sched.cal.usersFetcher = function( calendar, callback ) {

    var users = new sched.model.Users( [], { teamId: calendar.data('teamid'),
                                             projectId: calendar.data('projectid'),
                                             showType: calendar.data( 'showtype' ) });

    users.fetch({
        success: function( res ) {
            callback( res.models );
        }
    });

};

sched.cal.initToolTips = function() {
    $('.calendar .user').tipsy({
        'gravity': 'e',
        'live': true,
        'offset': -5
    });
};

/**
 * Initialise the calendar
 *
 */
sched.cal.init = function() {

    var calendar = $( this );
    var showType = calendar.data( 'showtype' );
    var startDate = calendar.moment( 'startdate' );
    var endDate = calendar.moment( 'enddate' );
    var wrapper = $( '<div></div>' ).addClass( 'calendar-wrapper' );
    var userFetcher = ( showType == 'user' )
        ? sched.cal.userFetcher
        : sched.cal.usersFetcher;
    sched.cal.initToolTips();
    startDate.subtract( 'days', 7 );
    calendar.append( sched.tpl.calendar() )
            .wrap( wrapper );

    userFetcher( calendar, function( users ) {
        sched.cal.initUsers( calendar, users );
        sched.cal.loadEntries({
            calendar: calendar,
            startDate: startDate,
            endDate: endDate,
            callback: function() {
                sched.cal.scroller.init( calendar );
                sched.cal.editor.init( calendar );
                sched.cal.util.shakeDown( calendar );
            }
        });
    });

};

