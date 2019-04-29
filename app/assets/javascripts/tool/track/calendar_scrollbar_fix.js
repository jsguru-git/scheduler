/*global alignGrid*/
// Fixes the calendar width percentages in browsers that have fixed scrollbar
$(document).ready(function(){

	alignGrid();

	$(window).resize(function() {
        alignGrid();
    });
});

function alignGrid() {
	if(navigator.appVersion.indexOf('Mac') == -1 || typeof($.browser.webkit) == 'undefined') {

		var newSize = $('#inner_timing_grid').width() * 0.13;
		$('#title_grid .day_container').width(newSize);

	}
}