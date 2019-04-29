/*global sched invoiceCreation */

var new_invoice_creation;

$(function() {
  // Datepicker for invoice cration
  $( "#invoice_form .datepicker" ).datepicker({
      dateFormat: 'yy-mm-dd',
      firstDay: 1
  });
            
  $('#invoice_form .cal_icon').click(function() {
      var idx = $('#invoice_form .cal_icon').index(this);
      $('#invoice_form .datepicker').eq(idx).trigger('focus');
      return false;
  });
  
  
   /**
    * Invoice creation
    */
   if ($("#invoice_form").length > 0) {
      new_invoice_creation = new invoiceCreation();
      new_invoice_creation.initialize({});
   }
   
  
});