/*global _ Backbone JST MemberView */

var TeamView = Backbone.View.extend({

    template: JST["tool/team/templates/team"],

    initialize: function(options) {
        _.extend(this, options);

        this.model.on('change', this.render, this);
        var model = this.model;

        $('input.submit').click(function(){
            model.set('name', $('#team_name').val());
            model.save({ wait: true });
        });

        this.render();

    },

    render: function() {
        var view = this;
        var team = this.model;
        this.$el.html(this.template());

        var items = [];
        if(team.get('users') instanceof Backbone.Collection) {
            this.model.get('users').each(function(user){
                var item = new MemberView({ user: user, team: team });
                items.push(item.render().el);
            });
        }

        this.$el.children('ul:first').append(items);
    }

});
