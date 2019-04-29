
/*global _ sched Backbone moment */

sched.ns( 'model' );

sched.model.Entry = Backbone.Model.extend({

    /**
     * Return url to fetch/save
     *
     * @return String
     */
    url: function() {

        var id = this.get( 'id' );

        return id
            ? '/calendars/entries/' +id+ '.json'
            : '/calendars/entries.json';

    },

    /**
     * Save the position of the entry in the calendar
     *
     * @param jQuery calendar
     * @param jQuery entry
     */
    onChangePosition: function( calendar, entry ) {

        var format = 'YYYY-MM-DD';
        var row = entry.parent();
        var pos = entry.position();
        var days = Math.floor( entry.width() / sched.cal.pxCellWidth );
        var start = moment( sched.cal.util.dateFor(calendar,pos), format );
        var end = start.clone();

        end.add( 'days', days - 1 );

        this.save({
            start_date: start.format( format ),
            end_date: end.format( format ),
            user_id: row.data( 'userid' )
        });

        this.trigger( 'rowChanged' );

    },

    /**
     * Returns a Moment for the named date field
     *
     * @param String name
     *
     * @return Moment
     */
    moment: function( name ) {

        return moment(
            this.get( name ),
            sched.cal.DATE_FORMAT
        );

    }

});

