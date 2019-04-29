/*global _, sched */

sched.ns( 'elements' );

sched.elements.DayTabs = function( options ) {
    $.extend( this, options );
    this.container = $( options.container );
};

sched.elements.DayTabs.prototype = {
		
  init: function() {

    $('.day_tabs li a', this.container)
        .bind('click', _.bind(this.onClick,this));	
    },
		
    onClick: function( evt ) {

    var anchor = $( evt.target );
		
    // Hide existing area
    $('.selected', this.container).removeClass('selected');

    // Get clicked link index
    var index = $('.day_tabs li a', this.container).index(anchor);
    
    // Show new area
	  $('ul.day_tabs li:eq('+index+')', this.container).addClass('selected');
    $('.day_content div.area:eq('+index+')', this.container).addClass('selected');

	  return false;

    }
};
