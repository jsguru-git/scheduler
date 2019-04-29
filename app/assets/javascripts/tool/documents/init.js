/*global sched commentCreation */

var new_comment_creation;

$(function() {

    /**
    * Comment creation
    */
    if ($("#document_list_cont").length > 0) {
        new_comment_creation = new commentCreation();
        new_comment_creation.initialize({});
        
        
        /**
         * Fire provider folder browser url if needed (for after oauth callback)
         */
        $('.action_links [data-call-on-load="true"]').each(function( index ) {
            //debugger;
            $.ajax({
                type: 'GET',
                url: $(this).attr('href'),
                beforeSend: function(xhr, settings) {
                    xhr.setRequestHeader('accept', '*/*;q=0.5, ' + settings.accepts.script);
                    $('#action_link_spinner').show();
                },
                complete: function(xhr, text_status) {
                    $('#action_link_spinner').hide();
                }
            });
        });
    }

});