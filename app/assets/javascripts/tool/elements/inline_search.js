/**
 * Inline search - Searches elements on a given page and highlights when found
 *
 * Example usage:
 * var inline_search_highlight = new inlineSearch();
 * inline_search_highlight.initialize({})
 */


/**
 * inlineSeach constructor
 *
 * @constructor
 * @this {inlineSeach}
 */
 /* usually var inlineSearch = function() {  */
window.inlineSearch = function() {
  this.options = {
    form_id: '#inline_search',
    search_within: '.display_title'
  };
};


window.inlineSearch.prototype = {


  /**
   * Initialize the search.
   *
   * @param {hash} options Options to override the defaults.
   */
  initialize: function(options) {
    this.options = $.extend(this.options, options);

    this.observe_search();
  },


  /**
   * Observe all fields inside the form and when changed perorm required actions.
   */
  observe_search: function() {
    var self = this;
    var timer;

    $(self.options.form_id).keyup(function() {
      clearTimeout(timer);
      var ms = 500; // milliseconds
      var search_value = $('input[type="text"]', this).val().toLowerCase();
      timer = setTimeout(function() {
        self._remove_search_class_records();
        self._perform_search(search_value);
      }, ms);
    });
  },

  /**
   * Updates the counter which displays the number of features
   *
   */
  updateFeatureCount: function() {
    var visible = $('.inline_search_highlight').length;
    $('#feature_count').html(visible);
  },

  /**
   * Perform search for the given value
   *
   * @private
   * @param {string} search_value The value to search for.
   */
  _perform_search: function(search_value) {
    if (search_value !== '') {
      $(this.options.search_within).each(function(index, title_element) {
        // If contains search value
        if ($(title_element).text().toLowerCase().indexOf(search_value) != -1) {
          $(title_element).parent('li').addClass('inline_search_highlight');
        } else {
          $(title_element).parent('li').addClass('inline_search_non_highlight');
        }
      });
      this.updateFeatureCount();
    }
  },


  /**
   * Remove all old search highlights
   *
   * @private
   */
  _remove_search_class_records: function() {
    $('.inline_search_highlight').removeClass("inline_search_highlight");
    $('.inline_search_non_highlight').removeClass("inline_search_non_highlight");
  }
};