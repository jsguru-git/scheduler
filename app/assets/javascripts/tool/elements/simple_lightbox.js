(function($) {

    $.fn.SimpleLightbox = function(options){

        options = $.extend( {
            container: '#main_lightbox',
            container_content: '#main_lightbox_content',
            container_background: '#main_lightbox_background',
            top_left_container: '#content',
            lightbox_width: 780
        }, options );

        return {

            init: function() {
		
                var self = this;

                // Close when background is clicked
                $('#main_lightbox_background').bind('click', function() {
                    self.close();
                    return false;
                });

                // Close button
                $('#main_lightbox_close').bind('click', function() {
                    self.close();
                    return false;
                });

            },

            open : function() {
                this.set_lightbox_position();
                this.show_background();
                this.show_lightbox();
                this._observe_cancel_links(this);
            },
            
            re_observe_cancel_links : function() {
                this._observe_cancel_links(this);
            },

            close : function() {
                this.hide_lightbox();
                this.hide_background();
            },

            change_height_to : function(new_height) {
                $(options.container_content).css( {
                    height: new_height
                });
            },

            change_width_to: function(new_width) {
                $('.simple_lightbox .simple_lightbox_content').css({
                    width: new_width
                });
                options.lightbox_width = new_width;
            },

            show_lightbox : function() {
                $(options.container).fadeIn(200);
            },

            show_background : function() {
                $(options.container_background).show();
            },
	    
            hide_lightbox : function() {
                document.getElementById('main_lightbox_content').innerHTML = '';
                $(options.container).fadeOut(200);
            },

            hide_background : function() {
                $(options.container_background).hide();
            },

            set_lightbox_position : function() {
                // Top
                var scroll_value = document.documentElement.scrollTop > 
                                   document.body.scrollTop ? 
                                   document.documentElement.scrollTop : 
                                   document.body.scrollTop;

                // Left
                var po_offset = $(options.top_left_container).offset();
                var whole_width = $(options.top_left_container).width();
                var center_width = (whole_width - options.lightbox_width) / 2;

                $(options.container).css( {
                    left: (po_offset.left + center_width),
                    top: (scroll_value + 100)
                });
            },
            
            // observe any content cancel links
            _observe_cancel_links : function(current_instance) {
                $('.lightbox_close').bind('click', function() {
                    current_instance.close();
                    return false;
                });
            }
            

        };
    };

})(jQuery);

