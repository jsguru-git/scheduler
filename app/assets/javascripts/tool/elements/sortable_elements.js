(function($) {

    $.fn.SortableElements = function(options){

        options = $.extend( {
            list_class: '.sortable',
            multiple_list_connect: '.sortable'
        }, options );

        return {

            init: function() {
                var self = this;
                self._setup_sortable_list();
            },

            re_apply_sortable : function() {
                this._setup_sortable_list();
            },

            // Setup the list to be sortable
            _setup_sortable_list : function() {
                $( options.list_class ).sortable({
                    connectWith: options.multiple_list_connect,
                    axis: 'y',
                    handle: '.move_handle',
                    opacity: 0.7,
                    update : function () {
						
						            var data_to_send = $(this).sortable('serialize');
			                  data_to_send = data_to_send + '&feature_id=' + $(this).data('feature-id');
						
						            $.ajax({
                            type: 'POST',
                            url: $(this).data('update-url'),
                            data: data_to_send
						            });
					          }
                }).disableSelection();
            }
        };
    };

})(jQuery);
