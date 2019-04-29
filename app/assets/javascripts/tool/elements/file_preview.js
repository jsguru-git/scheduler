/*global escape: true */
(function($) {
  var options;

  function handleFileSelect(evt) {

    var files = evt.target.files; // FileList object

    // Loop through the FileList and render image files as thumbnails.
    for (var i = 0; i < files.length; i++) {
      var f = files[i];
      // Only process image files.
      if (!f.type.match('image.*')) {
        continue;
      }

      var reader = new window.FileReader();

      // Closure to capture the file information.
      reader.onload = (function(theFile) {
        return function(e) {
          // Render thumbnail.
          var span = document.createElement('span');
          span.innerHTML = ['<img class="thumb" src="', e.target.result, '" title="', escape(theFile.name), '"/>'].join('');
          document.getElementById(options.previewElement).insertBefore(span, null);
        };
      })(f);

      // Read in the image file as a data URL.
      reader.readAsDataURL(f);
    }
  }

  $.fn.filePreview = function(user_options) {
    var defaults = {
      previewElement: $(this).attr('id') + '_preview'
    };
    options = $.extend({}, defaults, user_options);

    document.getElementById($(this).attr('id')).addEventListener('change', handleFileSelect, false);
  };

})(jQuery);
