/*global _ */

/**
 * Quote settings - Handles all javascript related to setting the defaults within quotes
 *
 * Example usage:
 * var new_quote_settings = new quoteSettings();
 * new_quote_settings.initialize({});
 */
 
 
 /**
  * quoteSettings constructor
  *
  * @constructor
  * @this {quoteSettings}
  */
window.quoteSettings = function() {
    this.options = {
        section_list_id: '#layout_list'
    };
};


window.quoteSettings.prototype = {
    
    
    /**
     * Initialize the creation view.
     *
     * @param {hash} options Options to override the defaults.
     */
    initialize: function(options) {
        this.options = $.extend(this.options, options);
        this._hide_submit_button();
        this._observe_input_value_change_and_save();
        this._setup_sortable_list();
    },
    
    
    /**
     * Hide the submit button for when JS is enabled
     */
    _hide_submit_button :  function() {
        $(this.options.section_list_id  + ' .submit').hide();
    },
    
    
    /**
     * Observe on chnage and save updates
     */
    _observe_input_value_change_and_save : function() {
        var self = this;
        
        var onChange = _.debounce(function() {
            self._save_updates(this);
        }, 800);
        
        $(self.options.section_list_id).on("keyup", 'input.text, textarea.text', onChange);
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
        
        $( self.options.section_list_id ).sortable({
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