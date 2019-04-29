
/*global _, sched, track, moment */

/**
 * Underscore mixin to create namespace from specified root
 *
 * @param Object curr
 * @param String nsString eg. 'foo.bar.baz'
 */
_.mixin({
    ns: function( curr, nsString ) {
        _.each(
            nsString.split( '.' ),
            function( part ) {
                if ( !curr[part] ) {
                    curr[ part ] = {};
                }
                curr = curr[ part ];
            }
        );
    }
});

/**
 * Underscore mixin for easy partial functions.
 *
 * eg. _.partial( func, x, y, z )
 *
 */
_.mixin({
    partial: function( func ) {
        var args = Array.prototype.slice.call( arguments, 1 );
        return this.bind.apply(
            this,
            [ func, {} ].concat( args )
        );
    }
});

/**
 * jQuery function to set something by position
 *
 * @param Object pos eg. {left:100,top:50}
 * @param Function placer eg. $.fn.css
 */
$.fn.pos = function( pos, placer ) {
    return ( placer || $.fn.css ).call(
        this,
        { left: pos.left + 'px',
          top: pos.top + 'px' }
    );
};

/**
 * jQuery function to get/set a Moment to/from an elements
 * named data attribute.
 *
 * @param String name (defaults to 'date')
 * @param Moment value (only for setting value)
 *
 * @return Moment
 */
$.fn.moment = function( name, value ) {
    return value
        ? this.data( name,
                     value.format(sched.cal.DATE_FORMAT) )
        : moment( this.data( name || 'date' ),
                  sched.cal.DATE_FORMAT );
};

/**
 * Indicates if a permission exists on the element.  Permissions are managed
 * using CSS classes on DOM elements, so they can be easily checked and
 * also styled against.
 *
 * @param String name
 *
 * @return boolean
 */
$.fn.can = function( name ) {
    return this.hasClass( 'can-' +name );
};

/**
 * Adds a class name temporarily to an element
 *
 * @param String clsName
 * @param int timeout (in milliseconds)
 *
 * @return jQuery
 */
$.fn.tempClass = function( clsName, timeout ) {
    var element = this.addClass( clsName );
    setTimeout(function() {
        element.removeClass( clsName );
    }, timeout || 2000 );
    return this;
};

/**
 * Add a mobile 'touch' event handler to an element
 *
 * @param Function handler
 *
 * @return jQuery
 */
$.fn.touch = function( handler ) {

    var moved = false;
    var originalEvt = null;

    this.bind( 'touchstart', function( evt ) {
        moved = false;
        originalEvt = evt;
    });

    this.bind( 'touchmove', function() {
        moved = true;
    });

    this.bind( 'touchend', function( evt ) {
        if ( originalEvt && !moved ) {
            handler( originalEvt );
            originalEvt = null;
        }
    });

    return this;

};

/**
 * Turn select controls into 'fancy' Select2 ones
 *
 * @param options {object}
 *
 * @return {jQuery}
 */
$.fn.fancySelect = function(options) {

    var DISABLE_SEARCH = -1;
    var defaults = {
        minimumResultsForSearch: DISABLE_SEARCH
    };

    return this
        .not('.select2-offscreen')
        .select2(
            $.extend(options, defaults)
        );
};

/**
 * Add a handler on key up for particular keyCode
 *
 * @param integer keyCode
 * @param Function handler
 *
 * @return jQuery
 */
$.fn.onkey = function(keyCode, handler) {

    return this.keyup(function(evt) {
        if (evt.keyCode == keyCode) {
            handler(evt);
        }
    });
};

/**
 * jQuery pseudo scroll start/stop events, modified from:
 * http://james.padolsey.com/javascript/special-scroll-events-for-jquery/
 *
 */
(function(){

    var special = jQuery.event.special,
        uid1 = 'D' + (+new Date()),
        uid2 = 'D' + (+new Date() + 1),
        latency = 300;

    var make = function( type, uid, immediate ) {
        special[ type ] = {
            setup: function() {
                var handler = _.debounce(
                    function(evt) {
                        evt.type = type;
                        jQuery.event.handle.apply(this, arguments);
                    },
                    latency,
                    immediate
                );
                jQuery(this).bind('scroll', handler)
                            .data(uid, handler);
            },
            teardown: function(){
                jQuery(this).unbind( 'scroll', jQuery(this).data(uid) );
            }
        };
    };

    make( 'scrollstart', uid1, true );
    make( 'scrollstop', uid2 );

})();


/**
* Used when adding a new rate card to a feature to add the correct id (only works when there is one select or input)
*/
function update_nested_id(container_id) {
    var path_string = '#' + container_id;
    var new_id = $(path_string + ' select').length - 1;
    var select_name = $(path_string + ' select').eq(new_id).attr("name").replace('0', new_id);
    var input_name = $(path_string + ' input[type="text"]').eq(new_id).attr("name").replace('0', new_id);
    window.setTimeout(function() {
        $(path_string + ' select').eq(new_id).attr("name", select_name);
        $(path_string + ' input[type="text"]').eq(new_id).attr("name", input_name);
    }, 500);
}

// Show tasks header bar when tasks exist
function task_header_bar_visibility() {
    if ($('#no_associated_features .sortable li.task').size() == 0) {
        $('#no_associated_features .header').hide();
        $('#no_associated_features ul .placeholder').show();
    } else {
        $('#no_associated_features .header').show();
        $('#no_associated_features ul .placeholder').hide();
    }
}

// /**
// * Used when adding a new nested element and there are multiple fields to a feature to add the correct id
// */
// function update_multiple_nested_id(container_id, line_class) {
//     var path_string = '#' + container_id;
//     var new_id = $(path_string + ' .' + line_class).length - 1;
//     
//     window.setTimeout(function() {
//         // Loop over selects
//         $(path_string + ' .' + line_class).eq(new_id).find('select, input[type="text"]').each(function( index ) {
//             var new_name = $(this).attr("name").replace('0', new_id);
//             $(this).attr("name", new_name);
//         });
//     }, 500);
// }


// sched namespace

window.sched = {};
window.sched.ns = _.partial( _.ns, window.sched );

// track namespace

window.track = {};
window.track.ns = _.partial( _.ns, window.track );

// user namespace

window.user = {};
window.user.ns = _.partial( _.ns, window.user );
