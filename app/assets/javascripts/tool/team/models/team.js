/*global _ Backbone Users */

var Team = Backbone.Model.extend({
    initialize: function(options) {
        _.extend(this, options);

        if(this.id) {
            this.fetch();
        } else {
            this.updateMembers();
        }
        this.on('sync', this.updateMembers, this);
    },

    addMember: function(user) {
        this.get('users').add(user);
        this.trigger("change");
    },

    removeMember: function(user) {
        this.get('users').remove(user);
        this.trigger("change");
    },

    updateMembers: function(){
        if(this.id) {
            this.set({ users: new Users(this.get('users')) });
        } else {
            this.set({ users: new Users() });
        }
    },

    url: function() {
        if (this.isNew()) {
            return "/team_api/teams.json";
        } else {
            return "/team_api/teams/" + this.id + ".json";
        }
    }
});
