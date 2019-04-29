/*global _ sched */

sched.ns( 'elements' );

sched.elements.calendarFilterHide = function( mask, popup ) {
    popup.hide();
    mask.hide();
    return false; // Cancel event default
};
	
sched.elements.calendarFilterShow = function( mask, popup ) {
    mask.show();
    popup.show();
    return false; // Cancel event default
};

sched.elements.calendarFilterInit = function() {

    var mask = $( '.date_range_selection_background' );
    var popup = $( '.date_range_selection' );
    var hide = _.partial( sched.elements.calendarFilterHide, mask, popup );

    $( '.cancel', popup )
        .add( mask )
        .click( hide );

    $( "#from_date", popup ).datepicker({ 
        altField: 'input#start_date_range', 
        dateFormat: 'yy-mm-dd',
        firstDay: 1,
        defaultDate: $( '#start_date_range', popup ).val()
    });

	$( "#end_date", popup ).datepicker({ 
        altField: 'input#end_date_range', 
        dateFormat: 'yy-mm-dd',
        firstDay: 1,
        defaultDate: $( '#end_date_range', popup ).val()
    });

    $( this ).click( _.partial(sched.elements.calendarFilterShow,mask,popup) );

};
