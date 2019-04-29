/*global sched inlineSearch
  global sched commentCreation
  global sched quoteSettings
  global sched projectPercentageTimeSpent
  global TopOfPage topOfPage */

var main_lightbox;
var main_notification;
var standard_estimate;
var item_sortable;
var inline_search_highlight;
var new_project_comment_creation;

$(function() {
    /**
    * Flash message removal after 3 seconds.
    */
    $('.flash_notification').delay(3000).slideUp();

    var topOfPage = new TopOfPage();

    /**
     * Lightboxes
     */
    main_lightbox = $('.simple_lightbox').SimpleLightbox();
    main_lightbox.init();

    // Show / hide elements if JS is turned on
    $('.js_show').show();
    $('.js_hide').hide();

    /**
     * Show / hide spinner for ajax requests
     */
    $("*[data-spinner]").live('ajax:beforeSend', function(e){
        $('#' + $(this).data('spinner')).show();
    });

    $("*[data-spinner]").live('ajax:complete', function(){
        $('#' + $(this).data('spinner')).hide();
    });


    /**
     * Lightboxes
     */
    main_notification = $('#notificaiton_container').SimpleNotification();
    main_notification.init();

    /**
	   * Sortable tasks on standard requirements / tasks page
	   */
    if ($("#tasks_index").length > 0){
        item_sortable = $('#tasks_index').SortableElements();
        item_sortable.init();
    }

    /**
     * Colour picker for project
     */
    $('#project_color').colorPicker({
        colors: ["B7C18F", "C1B58F", "C19D98", "C1A3B2",
                 "B8A7C1", "A9ACC1", "ACBFC1", "A6C1AD"]
    });

    /**
     * Expandable coloumn
     */
    $('.expandable_link').bind('click', function() {
        $('.main_content .expandable_content', $(this).parent()).slideDown();
        // Hide buttons
        $(this).hide();
        $('.shrink_link', $(this).parent()).show();
        return false;
    });

    $('.shrink_link').bind('click', function() {
        $('.main_content .expandable_content', $(this).parent()).slideUp();
        // Hide buttons
        $(this).hide();
        $('.expandable_link', $(this).parent()).show();
        return false;
    });

    /**
     * DayTabs
     */
    var my_schedule = new sched.elements.DayTabs({
        container: '#my_schedule'
    });
    my_schedule.init();

	  /**
     * SimpleTabs
     */
    var load_time = new sched.elements.SimpleTabs({
        container: '#lead_filter'
    });

    load_time.init();

	  var chart_filter = new sched.elements.SimpleTabs({
        container: '#chart_filter'
    });

    chart_filter.init();

    /**
     * Auto submit on form change
     */
    $('.submit_on_change').change(function() {
        $(this).closest("form").submit();
    });
    
    
    /**
     * Ajax auto submit on form change
     */
    $('.ajax_put_submit_on_change').change(function() {
        $.ajax({
            type: "PUT",
            url: $(this).closest("form").attr('action'),
            data: $(this).closest("form").serialize(), // serializes the form's elements.
            beforeSend: function(xhr, settings) {
                xhr.setRequestHeader('accept', '*/*;q=0.5, ' + settings.accepts.script);
            }
        });
    });

    /**
     * Change to manual on project status change
     */
    $('#projects_edit #project_project_status').change(function() {
        $('#projects_edit #project_project_status_overridden_true').attr('checked',true);
    });
    

    /**
     * Calendar filter
     */
    $( '#select_calendar' ).each( sched.elements.calendarFilterInit );

    /**
     * Initialise any calendars on the page
     */
    $( '.calendar' ).each( sched.cal.init );

    /**
     * Util dropdown (touch event for ios)
     */
    $("#util_container #right_util .drop_down_button").bind('touchstart', function() {
        $("#util_container #right_util ul.util_dropdown").toggle();
    });

    /**
     * Change estiamte project when select box is changed
     */
    $('#estimate_project_select').change(function() {
        var project_url = '/estimate/projects/' + $('select#id', this).attr('value');
        window.location.href = project_url;
    });

		/**
	   * Standard estimation form
	   */
    if ($("#standard_estimation_container").length > 0) {
        standard_estimate = $('#standard_estimation_container').StandardEstimation();
        standard_estimate.init();
    }


    if ($("#project_comments_index").length > 0) {
        new_project_comment_creation = new commentCreation();
        new_project_comment_creation.initialize({
            parent_class: '.document_comment_cont'
        });
    }

    $('.select_container select').fancySelect();

    
    /**
     * projects_percentage_time_spent report 
     */
    if ($("#reportsprojects_percentage_time_spent").length > 0) {
        var time_sepnt = new projectPercentageTimeSpent();
        time_sepnt.initialize({});
    }

	
	/**
	 * Reports page
	 */
	if ($("#reportspages_index").length > 0) {
		$("#select_section select").change(function() {
			var selected_value = $(this).val();
			
			if (selected_value === '') {
				$('.section').show();
			} else {
				$('.section').hide();
				$('#' + selected_value).show();
			}
		});
	}
	
	
	/**
	 * Quote settings
	 */
	if ($('#settings_quote').length > 0) {
        var new_quote_settings = new quoteSettings();
        new_quote_settings.initialize({});
	}
	
});
