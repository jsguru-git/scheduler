(function($) {

$.fn.SimpleNotification = function(options){


  options = $.extend( {
    container_class: '#notificaiton_container',
    display_for: 3000
  }, options );
  
  
  return {
    
    
    init: function() {
      
    },
    
    
    // Set the message and show for x amount of time
    display_message : function(message) {
      this._set_text(message);
      this._show_notification_message();
      this._adjust_width_to_fit_text();
    },
    
    
    // Set the message
    _set_text : function(message) {
      $(options.container_class + ' p span').text(message);
    },
    
    
    // Show a message for x number of seconds
    _show_notification_message : function() {
      $(options.container_class).show().delay(options.display_for).fadeOut("slow");
    },
    
    
    // Change width
    _adjust_width_to_fit_text : function() {
      var text_width = $(options.container_class + ' p span').width() + 20;
      if (text_width > 600) {
        text_width = 600;
      }
      $(options.container_class + ' p').width(text_width + 'px');
    }
    
    
  };
};

})(jQuery);