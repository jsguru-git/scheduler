/**
 * Project percentage time spent report javascript.
 *
 * Example usage:
 * var time_sepnt = new projectPercentageTimeSpent();
 * time_sepnt.initialize({});
 */
 
 
/**
 * projectPercentageTimeSpent constructor
 *
 * @constructor
 * @this {invoiceCreation}
 */
window.projectPercentageTimeSpent = function() {
    this.options = {
        team_selection_cont_id: '#team_selection_cont',
        checkbox_class: '.team_selection',
        team_container_class: '.team'
    };
};


window.projectPercentageTimeSpent.prototype = {


    /**
     * Initialize the view.
     *
     * @param {hash} options Options to override the defaults.
     */
    initialize: function(options) {
       this.options = $.extend(this.options, options);

       this._hide_or_unhide_unselected_teams();
       this._observe_check_boxs();
       this._observe_select_all_links();
    },
   
   
    /**
     * Observe the team checkbox changes
     */
    _observe_check_boxs: function() {
        var self = this;
        
        $(self.options.checkbox_class).change(function () {
            if( $(this).is(':checked') ) {
                self._show_team($(this).val());
            } else {
                self._hide_team($(this).val());
            }
            self._calculate_totals();
        });
    },
   
   
    /**
     * Show a team.
     * 
     * @param {int} team_id The id of the team to show
     */
    _show_team: function(team_id) {
        $("#team_" + team_id).show();
    },
   
   
   /**
     * hide a team.
     * 
     * @param {int} team_id The id of the team to hude
     */
    _hide_team: function(team_id) {
        $("#team_" + team_id).hide();
    },
   
   
    /**
     * Calculate the total figure based on what can currently be viewed.
     */
    _calculate_totals: function() {
        var total_team_project_mins = 0;
        var total_team_mins = 0;
       
        $(this.options.team_container_class + ':visible').each(function(){
            total_team_mins += parseInt($(this).data("total-team-mins"), 10);
            total_team_project_mins += parseInt($(this).data("total-team-project-mins"), 10);
        });

        // Total teams hours
        var total_team_hours = Math.floor(total_team_mins / 60);          
        var total_team_minutes = total_team_mins % 60;
        
        // team projects hours
        var total_team_project_hours = Math.floor(total_team_project_mins / 60);          
        var total_team_project_minutes = total_team_project_mins % 60;
        
		if (total_team_project_minutes < 10) {
			total_team_project_minutes = "0" + total_team_project_minutes;
		}
		
		var percentage = '0.00';
        if (total_team_mins !== 0) { 
            percentage = ((total_team_project_mins / total_team_mins) * 100).toFixed(1);
        }
        
        // Add to screen
        $('.totals .total_hours').text(total_team_hours + ':' + total_team_minutes);
        $('.totals .total_project_hours').text(total_team_project_hours + ':' + total_team_project_minutes);
        $('.totals .percentage').text(percentage+'%');
    },
    
    
    /**
     * Hide or un-hide selected teams based on current checkbox status.
     */
    _hide_or_unhide_unselected_teams: function() {
        var self = this;
         
        $(this.options.checkbox_class).each(function(){
            if( !$(this).is(':checked') ) {
                self._hide_team($(this).val());
            } else {
                self._show_team($(this).val());
            }
        });
         
        self._calculate_totals();
     },

     
     /**
      * Observe the select all and un-select all links and respond as required.
      */
    _observe_select_all_links: function() {
        var self = this;
         
        $("#select_all").click(function() {
             $( self.options.checkbox_class).each(function( index ) {
                 $(this).attr('checked', 'checked');
             });
             self._hide_or_unhide_unselected_teams();

             return false;
        });
         
        $("#unselect_all").click(function() {
            $( self.options.checkbox_class).each(function( index ) {
                $(this).attr('checked', false);
            });
            self._hide_or_unhide_unselected_teams();
            
            return false;
        });
    }
     
};