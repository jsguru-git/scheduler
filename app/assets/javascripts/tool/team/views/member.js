/*global _ Backbone JST */

var MemberView = Backbone.View.extend({

    template: JST["tool/team/templates/member"],

    events: {
        'click .delete' : 'remove'
    },

    initialize: function(options) {
        _.extend(this, options);
    },

    remove: function() {
        this.team.removeMember(this.user);
        $('select option[value=' + this.user.id + ']')[0].disabled = false;
        return false;
    },

    render: function() {
        this.$el.html(this.template(this));

        return this;
    }

});