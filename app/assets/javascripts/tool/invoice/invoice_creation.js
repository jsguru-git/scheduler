/**
 * Invoice creation - Handles all javascript to handle the synamic creation of an invoice
 *
 * Example usage:
 * var new_invoice_creation = new invoiceCreation();
 * new_invoice_creation.initialize({});
 */
 
 
 /**
  * invoiceCreation constructor
  *
  * @constructor
  * @this {invoiceCreation}
  */
window.invoiceCreation = function() {
    this.options = {
        form_id: '#invoice_form',
        invoice_item_line_class: '.invoice_item',
        invoice_item_container_id: '#payment_profile_list'
    };
};



window.invoiceCreation.prototype = {


   /**
    * Initialize the creation view.
    *
    * @param {hash} options Options to override the defaults.
    */
   initialize: function(options) {
       this.options = $.extend(this.options, options);
       
       this.setup_form();
       this.observe_remove_links();
       this.observe_currency_change();
       this.observe_add_links();
       this.observe_amount_change();
   },
   
   
   /**
    * Remove the no item message from the page
    */
   remove_no_item_message: function() {
       $('.no_content').remove();
   },
   
   
   /**
   * Update the nested id's of the invoice payment items
   */
   update_multiple_nested_id: function() {
       var self = this;

       window.setTimeout(function() {
           
           // Lopp over all lines
           $(self.options.invoice_item_container_id + ' ' + self.options.invoice_item_line_class).each(function( index ) {
               var new_id = index;
               
               // Loop over selects
                $(this).find('select, input[type="text"], input[type="hidden"]').each(function( index ) {
                    var new_name = $(this).attr("name").replace(/\d+/, new_id);
                    $(this).attr("name", new_name);
                });
            });
           
       }, 500);
   },
   
   
   /**
    * Observe all fields inside the form and when changed perorm required actions.
    */
    observe_remove_links: function() {
        var self = this;
        
        // Remove old observer first
        $(self.options.form_id + ' .invoice_item_remove').unbind("click");
     
        // Observe all remove buttons again
        $(self.options.form_id + ' .invoice_item_remove').click(function() {
            $(this).parents(self.options.invoice_item_line_class).remove();
            self.update_multiple_nested_id();
            return false;
        });
    },
    
    
    /**
    * Observe changes to the currency
    */
    observe_currency_change: function() {
        var self = this;
        
        $(self.options.form_id + ' #invoice_currency').change(function() {
            $(self.options.form_id + ' .currency_code').text($(this).val().toUpperCase());
            
            return false;
        });
    },
    
    
    /**
    * Obse links and also pass in additional params which are required
    */
    observe_add_links: function() {
        $('.create_invoice_item').click (function () {
            $.ajax({
                type: "GET",
                url: $(this).attr('href'),
                data: {
                    "currency": $('#invoice_currency').val()
                }
            });
          
            return false; // stop the browser following the link
        });
    },
    
    
    /**
    * Observe amount changes and update total amounts
    */
    observe_amount_change: function() {
        var self = this;
        var observe_path = self.options.form_id + ' .invoice_item .item_amount, ' + self.options.form_id + ' .invoice_item select, ' + self.options.form_id + ' .invoice_item .qty, #invoice_vat_rate';
        
        // Remove old observer first
        $(observe_path).unbind("change");
        
        $(observe_path).change(function() {
            self.update_total_values();
            
            return false;
        });
    },
    
    
    /**
    * Update the total values on page
    */
    update_total_values: function() {
        var self = this;
        
        var should_incl_vat = 0.0;
        var not_incl_vat = 0.0;
        
        var vat_rate = parseFloat($('#invoice_vat_rate').val());
        if (vat_rate === null || vat_rate === '' || isNaN(vat_rate) ) {
            vat_rate = 0;
        }

        //
        $(self.options.form_id + ' input.item_amount').each(function( index ) {
            var amount_value = parseFloat($(this).val());
            
            if (amount_value && !isNaN(amount_value)) {
                // Check to see if vat should be incldued or not
                var select = $('select', $(this).parents('.invoice_item')).val();
                
                // Get quantity
                var qty = parseInt($('.qty', $(this).parents('.invoice_item')).val(), 10);
                if (qty === null || qty === '' || isNaN(qty) ) {
                    qty = 0;
                }

                if (select == 'true') {
                    should_incl_vat += amount_value * qty;
                } else {
                    not_incl_vat += amount_value * qty;
                }
            }
        });
        
        var subtotal_amount = (should_incl_vat + not_incl_vat).toFixed(2);
        var vat_amount =  ((vat_rate / 100) * should_incl_vat).toFixed(2);
        var total = ((should_incl_vat + not_incl_vat) + ((vat_rate / 100) * should_incl_vat)).toFixed(2);
        
        $('.subtotal .currency_amount').text(subtotal_amount);
        $('.vat .currency_amount').text(vat_amount);
        $('.total .currency_amount').text(total);
    },
    
    
    /**
    * Check the correct values have been added to the dynamic areas.
    */
    setup_form: function() {
        var self = this;
        
        // Just incase someone refreshes page
        $(self.options.form_id + ' .currency_code').text($('#invoice_currency').val().toUpperCase());
    }
    
};