user.ns( 'view' );

user.view.BioView = Backbone.View.extend({

    el: '#bio_field',

    events: {
        'click #biography_text'     : 'convertToTextField',
        'click #submit_bio'         : 'updateBiography',
        'mouseover #biography_text' : 'highlight',
        'mouseout #biography_text'  : 'removeHighlight'
    },

    initialize: function(options) {
        _.extend(this, options);
        this.model = new user.model.User({ id: this.id });
        this.model.on('change', this.render, this);
        this.model.fetch();
    },

    updateBiography: function(e) {
        $('#biography_update_spinner').show();
        this.model.set('biography', $('#text_field_bio').val());
        this.model.save();
    },

    highlight: function() {
        this.$el.css("background-color", '#FCFFC9');
        this.$el.css("cursor", "pointer");
    },

    removeHighlight: function() {
        this.$el.css("background-color", '');
    },

    convertToTextField: function() {
        this.removeHighlight();
        this.model.save({
            success: this.render('field')
        });
    },

    biographyIsEditable: function() {
        if(this.$el.attr('class') == 'editable') {
            return true;
        } else {
            return false;
        }
    },

    getText: function(parsed) {
        if(this.model.get('biography') == null || this.model.get('biography') == "") {
            return 'No biography.'
        } else {
            if (parsed === true) {
                return this.model.get('parsed_biography');
            } else {
                return this.model.get('biography');
            }
        }
    },

    // Render function
    // type - Can be 'field' or 'text'.
    render: function(type) {
        if(this.biographyIsEditable()) {
            if(type == 'field') {
                $('#markdown_info').show()
                this.$el.html(_.template("<textarea rows=\"10\" cols=\"60\" id=\"text_field_bio\"> <%= getText(false) %> </textarea><input type=\"submit\" id=\"submit_bio\" value=\"Update biography\"></input><br /><small>You can use markdown in your biography.</small>", this));
            } else {
                $('#markdown_info').hide();
                this.$el.html(_.template("<p id=\"biography_text\"></p>"));
                $('#biography_text').html(this.getText(true));
            }
            $('#biography_update_spinner').hide();
        }
    }

});