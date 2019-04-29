/*global _ */

/**
 * Quote creation - Handles all javascript to handle the synamic creation of an quote
 *
 * Example usage:
 * var new_quote_creation = new quoteCreation();
 * new_quote_creation.initialize({});
 */
 
 
 /**
  * quoteCreation constructor
  *
  * @constructor
  * @this {quoteCreation}
  */
window.quoteCreation = function() {
    this.options = {
        'main_container_id': '#showing_quote',
        'activity_list_id': '#activity_list',
        'report_layout_list_id': '#report_layout_list'
    };
};


window.quoteCreation.prototype = {


    /**
     * Initialize the creation view.
     *
     * @param {hash} options Options to override the defaults.
     */
    initialize: function(options) {
        this.options = $.extend(this.options, options);
       
        this._hide_submit_button();
        this._update_type_fields();
        
        this._observe_input_value_change_and_save();
        this._setup_sortable_list();
    },
    
    
    /**
     * Highlight field due to failed validaiton
     */
    highlight_failed_reason : function(model_name, field_name, reason) {
        var self = this;
        var field_xpath = self.options.main_container_id + ' #' + model_name + '_' +  field_name;

        // Highlight field
        if ($(field_xpath).length > 0) {
            // Check doesnt already exist
            if ($(field_xpath).parent().attr('class') != 'field_with_errors') {
                $(field_xpath).wrap('<span class="field_with_errors" />');
            }
        }
      
        // Add reason to error list
        if ($(self.options.main_container_id + ' ul.validation_errors .' + field_name).length == 0) {
            $(self.options.main_container_id + ' ul.validation_errors').append('<li class="'+field_name+'">'+reason+'</li>');
        }
    },
   
   
    /**
     * Clear the reason error list
     */
    clear_all_error_alerts : function() {
        var self = this;
        
        // Remove error span containers
        $(self.options.main_container_id + ' .field_with_errors').each(function(index) {
            $(this).contents().unwrap();
        });
      
        // Remove messages
        $(self.options.main_container_id + ' ul.validation_errors').empty();
    },
   
   
    /**
     * Oberve the quote type radio buttons and alter form as required
     */
    _update_type_fields : function() {
        if ($('.type_radios').length > 0) {
            if ($('.type_radios:checked').val() === 'true') {
                $('#quote_type_true').show();
                $('#quote_type_false').hide();
            
                $('#copy_activity_button').hide();
            } else {
                $('#quote_type_true').hide();
                $('#quote_type_false').show();
            
                $('#copy_activity_button').show();
            }
        }
    },
    
    
    /**
     * Hide the submit button for when JS is enabled
     */
    _hide_submit_button :  function() {
        $('.submit').hide();
    },
    
    
    /**
     * Observe on chnage and save updates
     */
    _observe_input_value_change_and_save : function() {
        var self = this;
        
        var onChange = _.debounce(function() {
            self._save_updates(this);
        }, 800);
        
        $(self.options.main_container_id).on("keyup", 'input.text, input.number, textarea.text', onChange);
        
        $(self.options.main_container_id).on("change", 'select, input.checkbox', function() { 
            self._save_updates(this);
        });
        
        $(self.options.main_container_id).on("change", '.type_radios', function() { 
            self._update_type_fields();
            self._save_updates(this);
        });
    },
    
    
    /**
     * Create a put request and save changes in the form
     */
    _save_updates : function(field) {
        $.ajax({
            type: 'PUT',
            url: $(field).parents('form').attr('action'),
            data: $(field).parents('form').serializeArray(),
            beforeSend: function(xhr, settings) {
                xhr.setRequestHeader('accept', '*/*;q=0.5, ' + settings.accepts.script);
            }
        });
    },
    
    
    /**
     * Setup the list to be sortable
     */
    _setup_sortable_list : function() {
        var self = this;
        $( self.options.activity_list_id ).sortable({
            axis: 'y',
            handle: '.move_handle',
            opacity: 0.7,
            items: "li.quote_activity",
            update : function () {
                $.ajax({
                    type: 'POST',
                    url: $(this).data('update-url'),
                    data: $(this).sortable('serialize')
                });
            }
        });
        
        $( self.options.report_layout_list_id ).sortable({
            axis: 'y',
            handle: '.move_handle',
            opacity: 0.7,
            update : function () {
                $.ajax({
                    type: 'POST',
                    url: $(this).data('update-url'),
                    data: $(this).sortable('serialize')
                });
            }
        });
    }
    
    
};