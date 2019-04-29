/*global _ Backbone */

var TopOfPage = Backbone.View.extend({

  el: '#top_of_page',

  events: {
    'click' : 'scroll_to_top'
  },

  /**
  * Initializes a back to top of page button for Fleetsuite
  * Binds scrolling to a function.
  */
  initialize: function() {
    _.bindAll(this, 'detect_scroll');
    $(window).scroll(this.detect_scroll);
    this.displayed = false;
    this.render();
  },

  /**
  * Called when the page is scrolled.
  */
  detect_scroll: function() {
    if(this.scroll_offset() > 200 && !this.displayed) {
      this.show_button();
    }

    if(this.scroll_offset() < 200 && this.displayed) {
      this.hide_button();
    }
  },

  /**
  * Shows the button, animating it on to the viewport
  */
  show_button: function() {
    this.displayed = true;
    this.$el.animate({
      top: '95.5%'
    }, 200, 'easeOutSine');
  },

  hide_button: function() {
    this.displayed = false;
    this.$el.animate({
      top: '100%'
    }, 200, 'easeInSine');
  },

  /**
  * Scrolls the user to the top of the current page
  */
  scroll_to_top: function() {
    window.scrollTo(0, 0);
  },

  /**
  * Returns the current offset scroll to the window
  */
  scroll_offset: function() {
    return $(window).scrollTop();
  },

  render: function() {
    this.$el.html("<img src=\"../../assets/top_arrow.png\" />");
  }

});