/*global _ Backbone JST User */

var UserView = Backbone.View.extend({

    events: {
        'change select' : 'add'
    },

    initialize: function(options) {
        _.extend(this, options);

        this.$el.children('select').select2({
            placeholder: "Choose user to add"
        });
    },

    add: function(x) {
        var id = this.$el.children('select').select2('val');
        var team = this.model;

        if(id) {
            var user = new User({ id: id });
            user.fetch({
                success: function() {
                    team.addMember(user);
                }
            });
        }

        this.$el.find('select option[value=' + id + ']')[0].disabled = true;
        this.$el.children('select').select2('val', null);

    }

});