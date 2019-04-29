/*global main_lightbox _ Track track Backbone moment JST */

track.ns( 'view' );

// Generate modal overlay windows

track.view.Modal = Backbone.View.extend({

    template: JST["tool/track/templates/modal"],

    // CSS selectors for this view
    selectors: {
      lightbox  : '#main_lightbox_content',
      picker    : '#main_lightbox_content .datepicker',
      copy      : '#apply_copy',
      cancel    : '#cancel_copy',
      close     : '#main_lightbox_close'
    },

    initialize: function(options) {

        _.extend(this, options);

        this.render();
    },

    render: function() {

        var lightbox = this.selectors['lightbox'];

        $(lightbox).html(this.template({date: this.date}));

        window.main_lightbox.change_width_to(500);
        window.main_lightbox.change_height_to(300);
        window.main_lightbox.open();

        this.bindEvents.call(this);
    },

    /**
     * Returns the start and end dates from the jQuery UI Cal
     *
     * @return {object}
     */
    getValues: function() {

      var picker = this.selectors['picker'],
          start = $(picker).eq(0).val(),
          end   = $(picker).eq(1).val();

      return { start: start,
               end:   end };
    },

    bindEvents: function() {

        $( ".datepicker" ).datepicker({
            dateFormat: 'yy-mm-dd',
            firstDay: 1
        });

        $('.cal_icon').click(function() {
            var idx = $('.cal_icon').index(this);
            $('.copy_timesheet .datepicker').eq(idx)
                                            .trigger('focus');
            return false;
        });

        $(this.selectors['cancel']).on('click', _.bind(function() {
            $(this.selectors['close']).trigger('click');
            return false;
        }, this));

        $(this.selectors['copy']).on('click', _.bind(function() {
            var values = this.getValues();

            if (values['end'] === '') {
                $('.copy_timesheet .datepicker').eq(1).css({'border':'2px solid #F88'});
            } else {
              this.view.handleValues(values);
              window.main_lightbox.close();
            }
            return false;
        }, this));
    }
});

