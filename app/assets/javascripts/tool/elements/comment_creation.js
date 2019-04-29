/**
 * Comment creation - Handles all javascript related to creating a comment
 *
 * Example usage:
 * var new_comment_creation = new commentCreation();
 * new_comment_creation.initialize({});
 */
 
 
 /**
  * commentCreation constructor
  *
  * @constructor
  * @this {commentCreation}
  */
window.commentCreation = function() {
    this.options = {
        new_comment_link: '.new_comment_link',
        cancel_comment_link: '.cancel_comment_link',
        parent_class: 'li.document',
		reply_comment_link: '.reply_comment_link',
		cancel_reply_comment_link: '.cancel_reply_comment_link',
		reply_comment_container: '.comment_text'
    };
};



window.commentCreation.prototype = {
    
    
    /**
     * Initialize the creation view.
     *
     * @param {hash} options Options to override the defaults.
     */
    initialize: function(options) {
       this.options = $.extend(this.options, options);
       
       this.set_page_comments();
	   this.show_hide_reply_comments(null);
       this.observe_comment_links();
    },
   
    
    /**
     * Observe the new comment link
     */
    observe_comment_links: function() {
        var self = this;
        
        // Remove old observer first
        $(self.options.new_comment_link).unbind("click");
        $(self.options.cancel_comment_link).unbind("click");
        $(self.options.reply_comment_link).unbind("click");
		$(self.options.cancel_reply_comment_link).unbind("click");

        
        // Observe new and cancel links
        $(self.options.new_comment_link).click(function() {
            $('.new_comment_container', $(this).parents(self.options.parent_class)).show();
            return false;
        });
        
        $(self.options.cancel_comment_link).click(function() {
            $('.new_comment_container', $(this).parents(self.options.parent_class)).hide();
            $('.new_comment_link', $(this).parents(self.options.parent_class)).show();
            $('.new_comment_container textarea', $(this).parents(self.options.parent_class)).val('');
            return false;
        });

		$(self.options.reply_comment_link).click(function() {
			$('.reply_comment_container', $(this).parents(self.options.reply_comment_container)).show();
			$(this).parents('.comment_reply').hide();
            return false;
        });

		$(self.options.cancel_reply_comment_link).click(function() {
            $('.reply_comment_container', $(this).parents(self.options.reply_comment_container)).hide();
            $('.comment_reply', $(this).parents(self.options.reply_comment_container)).show();
            $('.reply_comment_container textarea', $(this).parents(self.options.reply_comment_container)).val('');
            return false;
        });
    },
    
    
    /**
    * Show new links and hide forms
    */
    set_page_comments: function() {
        $('.new_comment_link').show();
        $('.new_comment_container').hide();
    },
   

	/**
	 * Show / hide comment link / form
	 */
	show_hide_reply_comments: function(specific_comment) {
		if (specific_comment === null) {
			$('.reply_comment_link').show();
			$('.reply_comment_container').hide();
		} else {
			$('.reply_comment_link', specific_comment + ' .comment_text:eq(0)').show();
			$('.reply_comment_container', specific_comment + ' .comment_text:eq(0)').hide();
		}
	}
    
};