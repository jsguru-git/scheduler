/*global sched quoteCreation */

var new_quote_creation;


$(function() {

  
   /**
    * Invoice creation
    */
   if ($("#quotequotes_show").length > 0) {
      new_quote_creation = new quoteCreation();
      new_quote_creation.initialize({});
   }
   
   
});