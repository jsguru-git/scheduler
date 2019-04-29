/*global _ sched */

sched.ns( 'elements' );

sched.elements.SimpleTabs = function( options ) {
    $.extend( this, options );
    this.container = $( options.container );
};

var drawVisualization0 = drawVisualization0 || function() {};
var drawVisualization1 = drawVisualization1 || function() {};

sched.elements.SimpleTabs.prototype = {
		
    init: function() {
        $('ul.options li a', this.container).bind('click', _.bind(this.onClick,this) );	
    },
		
    onClick: function( evt ) {

		    var anchor = $( evt.target );
				
		    // Hide existing area
		    $('.selected', this.container).removeClass('selected');
		
        // Get clicked link index
		    var index = $('.options li a', this.container).index(anchor);
		
		    // Show new area
		    $('ul.options li:eq('+index+')', this.container).addClass('selected');
		    $('.simple_tabs_content_container div.inner_simple_tabs_content:eq('+index+')', this.container).addClass('selected');
		
        // Re-draw graph if needed
		    if ($(anchor).data('draw-visualization') == true) {
		        if (index == 0) {
				        drawVisualization0();
			      } else if (index == 1) {
				         drawVisualization1();
			      }
		    }
		
		    if(!$(anchor).hasClass('real_link')) {
			      return false;
		    }
    }
};
