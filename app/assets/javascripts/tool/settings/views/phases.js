/*global _ Backbone JST PhaseCollection Phase main_notification */
var phasesView = Backbone.View.extend({

    template: JST["tool/settings/templates/phases"],

    initialize: function(options) {
        _.extend( this, options );
        this.phasesCollection = new PhaseCollection();
        var view = this;
        this.phasesCollection.fetch({
            success: function() {
                view.render();
            }
        });
    },

    initSelect2: function() {
        var names = _.map(_.toArray(this.phasesCollection), function(phase) {
            return phase.get('name');
        });
        var view = this;
        $('.select2').select2({ tags: names,
                                width: '50%',
                                placeholder: 'Add some phases' });

        $('.select2').change(function(e) {
            if(e.added) {
                var newPhase = new Phase({ name: e.added.text });
                newPhase.save(null, {
                    success: function() {
                        view.phasesCollection.add(newPhase);
                    },
                    error: function() {
                        main_notification.display_message('Failed to add new phase');
                    }
                });
            } else {
                var phase = view.phasesCollection.where({ name: e.removed.text })[0];
                phase.destroy();
            }
        });
    },

    render: function() {
        this.$el.html(this.template(this));
        this.initSelect2();
    }

});