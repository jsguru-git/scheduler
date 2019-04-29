(function($) {

    // TODO SPACING IS OFF CHANGE TABS TO SPACES TO FIX INDENT
    $.fn.PricingSelect = function(options) {

        options = $.extend({}, options);

        return {

            init: function() {
                var self = this;
                self._calc_suite_price();

                $('ul.component_container li.account_component .plan').click(function() {
                    var click = this;
                    self.change_component(click);
                });

                $('ul.component_container li.account_component .select input').change(function() {
                    var click = this;
                    self.match_select_change(click);
                });
            },

            // Pricing tool selection
            change_component: function(click) {
                if ($('input', $(click).parent().parent()).is(':checked')) {
                    $(click).removeClass('selected');
                    $('input', $(click).parent().parent()).attr("checked", false);
                } else {
                    $(click).addClass('selected');
                    $('input', $(click).parent().parent()).attr("checked", true);
                }

                var input_id = '#' + $('input', $(click).parent().parent()).attr('id');
                this.match_select_change(input_id);
            },

            match_select_change: function(click) {
                var changed_class = $(click).attr('class');
                $('.' + changed_class).attr("checked", $(click).is(':checked'));
                this._calc_suite_price();
            },

            // protected 

            _calc_suite_price: function() {
                $('ul.plan_container li.account_plan').each(function(index, value) {
                    var plan_id = '#' + $(value).attr('id');
                    var plan_price = parseInt( $(plan_id + ' .plan_id')
                                         .attr('data-price'), 10 );
                    var component_price = 0;

                    $(plan_id + ' ul.component_container li input:checked').each(function(index) {
                        component_price += parseInt($(this).attr('data-price'), 10);
                    });

                    var total_price = 0;
                    if (component_price != 0) {
                        total_price = plan_price + component_price;
                    }

                    $(plan_id + ' .number').text(total_price);
                });
            }
        };
    };

})(jQuery);

