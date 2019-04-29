/*global console _ track moment Track */

// Shared view methods to reduce duplication
track.ns('lib');

track.lib = {

    RADIX: 10,

    /**
     * Logical negation
     *
     * @param {boolean} boolValue
     * @return {boolean} logical complement of boolValue
     */
    logicalNegation: function(boolValue) {

        return boolValue === true ? false : true;
    },

    /**
     *
     * Convenience function that plucks a set of attributes from a model
     * i.e pluckModel(model, ['id', 'started_at']);
     *
     * @param {Backbone model} model
     * @param {array} attributes
     *
     * @return array
     */
    pluckModel: function (model, attributes) {

        return _.map(attributes, function(attr) {
           return model.get(attr);
        });
    },

    /**
     * Returns the css top position of an element
     *
     * @param {object} element jQuery element
     * @return {number} int
     */
    topPosition: function(element) {

        return parseInt($(element).css('top'), this.RADIX);
    },

    /**
     * There are basically two types of date strings to handle
     * Tue Oct 30 2012 09:04:00 or 2012-10-31T14:40:00-08:00
     * Extracts the hours and minutes into an array from either string
     *
     * @param {string} time A time string
     * @return {array} [hours, minutes]
     */
    extractHoursMinutes: function(time) {

        var t;

        if (time.split(' ').length > 1) {
            t = time.split(' ')[4].split(':');
        } else {
            t = time.split('T')[1].split(':');
        }
        return t.slice(0, 2);
    },

    formatZeroValue: function(v) {
        if (v[0] === "0") {
            return v[1];
        }
        return v;
    },

    /**
     * Returns hours and minutes from a string in format
     * Tue Oct 30 2012 09:04:00
     *
     * @param {string} str time string
     * @return {array} hours and minutes
     */
    hmFromString: function(str) {

        var times = this.extractHoursMinutes(str);

        return _.map(times, _.bind(function(i) {
            return parseInt(this.formatZeroValue(i), this.RADIX);
        }, this));
    },

    timeWithOffset: function(time, offset) {

        return moment.utc(time).add('hours', offset).toString();
    },

    /**
     * Remove the time zone from a moment.js date string
     * @param {string} timeString
     */
    timeWithoutZone: function(timeString) {

        return moment(timeString).format("YYYY-MM-DDTHH:mm");
    },

    /**
     * This is a fix for overzealous grid position correction
     * If a models end time is before it's start time then this will
     * correct the error by setting the models end time to be 4 minutes after
     * it's start time
     *
     * @param {object} model Backbone.js model
     */
    catchNegativeTime: function(model) {

        var start = model.get('started_at'),
            end = model.get('ended_at');

        if (moment(start).isAfter(moment(end))) {
            model.set('ended_at', moment(start).add({
                minutes: 30
            }).format());
        }
    },

    /**
     * Returns the top and bottom position for an element
     *
     * @param  {el}     jQuery element
     * @return {object} top and bottom position
     *
     */
    position: function(el) {

        var topPos      = this.topPosition(el),
            height      = parseInt($(el).outerHeight(), 10);

        return {
          top: topPos,
          bottom: topPos + height
        };
    },

    // ====================================================================
    // COLLISION DETECTION
    // ====================================================================

    /**
     * Returns positions for all other elements in a column
     *
     *
     */
    getElementPositions: function(el, originalElement) {

        var parentColumn = el.parents('.day_container');

        var elements = parentColumn
                           .children('div:not(:eq(' + originalElement.index() + '))')
                           .children('.entry');

        return _.map(elements, _.bind(function(item) {
            return this.position(item);
        }, this));
    },

    /**
     * Gets only top or bottom positions for all other elements in a column
     *
     * @param {el} el jQuery element
     * @param {string} type top or bottom
     *
     * @return {array}
     */
    getColumnPositions: function(el, originalElement, type) {

        return _.map(this.getElementPositions(el, originalElement), function(item) {
            return type === 'top' ? item.top : item.bottom;
        });
    },

     /**
     * Check if a timing div touches an element above
     *
     * @return {boolean}
     */
    touchesElementAbove: function(element) {

        var el = element.children('.entry'),
            position = this.position(el),
            bottomPositions = this.getColumnPositions(el, element, 'bottom');

        if (bottomPositions.indexOf(position.top) !== -1) {
            return true;
        }
        return false;
    },

    /**
     * Check if the current timing touches an element below
     *
     * @return {boolean}
     */
    touchesElementBelow: function(element) {

        var el = element.children('.entry'),
            position = this.position(el),
            topPositions = this.getColumnPositions(el, element, 'top');

        if (topPositions.indexOf(position.bottom) !== -1) {
            return true;
        }
        return false;
    },

    /**
     * If an element touches another element
     * then nudge it up or down by one pixel
     * @param {HTML} element
     * @param {object} view Backbone.js view
     */
    ensureSafePosition: function(element, view) {

        var pos = this.position(element.find('.entry'));

        if ( this.touchesElementAbove(element) === true ) {
            view.setY(pos.top + 1);
        }
        if (this.touchesElementBelow(element) === true) {
            view.setY(pos.top - 1);
        }
    },

    // ====================================================================
    // GHOST DIV DETECTION
    // ====================================================================

    /**
     * Return all items in a column
     * Returns array pair of top and bottom position for all elements
     *
     * [topPosition, bottomPosition]
     */
    columnElements: function() {

        var elements = $('.ghost').parents('.day_container').find('.entry');

        var element_map = _.bind(function() {

                return _.map(elements, _.bind(function(element) {
                    var top = this.topPosition(element),
                        height = $(element).outerHeight();
                    return {
                        top: top,
                        bottom: (top + height)
                    };
                }, this));
            }, this);

        return this.sortByTopOffset(element_map());
    },

    /**
     * Elements need to be sorted in order of top offset to do
     * calculations.
     * @param {array} elements
     * @return {array} elements sorted by top offset
     */
    sortByTopOffset: function(elements) {

        return _.sortBy(elements, function(el) {
            return el['top'];
        });
    },

    /**
     * Returns the element directly above initial position
     * @param {array} elements
     * @param {number} position ghost current position
     */
    elementAbove: function(elements, position) {

        // Find matching candiates that are higher up on the grid than position
        var candidates = _.filter(elements, function(el) {
            return (el.top < position);
        });

        var sorted_candidates = this.sortByTopOffset(candidates);

        return (sorted_candidates.length > 0) ? sorted_candidates.pop() : null;
    },

    /**
     * Returns the element directly below initial position
     * @param {array} elements
     * @param {number} position
     */
    elementBelow: function(elements, position) {

        // Find matching candiates that are lower down the grid than position
        var candidates = _.filter(elements, function(el) {
            return (el.top > position);
        });

        var sorted_candidates = this.sortByTopOffset(candidates);
        return (sorted_candidates.length > 0) ? sorted_candidates[0] : null;
    },

    /**
     * Finds the upper and lower bounding elements
     * @param {number} initialPosition
     * @returns {object}
     *
     */
    boundingElements: function(initialPosition) {

        var boundingElements = this.columnElements();

        return {
            top: this.elementAbove(boundingElements, initialPosition),
            bottom: this.elementBelow(boundingElements, initialPosition)
        };
    },

    /**
     * Checks for an upper bounding element
     * @param {object} boundMap
     * @return {boolean}
     */
    hasUpperBound: function(boundMap) {

        return boundMap.top !== null;
    },

    touchesElement: function(element) {

        var entriesForColumn = $(element).parents('.day_container')
                                         .find('.entry');

        var elementTop = this.topPosition(element);

        return _.filter(entriesForColumn, _.bind(function(el) {
            var t = this.topPosition(el);
            return t === elementTop;
        }, this));
    },

    /**
     * Checks for a lower bounding element
     * @param {object} boundMap
     * @return {boolean}
     */
    hasLowerBound: function(boundMap) {

        return boundMap.bottom !== null;
    },

    /**
     * Finds the upper and lower bounds for a ghost element
     * @param {number} intitialPosition
     */
    getBounds: function(initialPosition) {

        var bounds = this.boundingElements(initialPosition),
            top = bounds.top,
            bottom = bounds.bottom;

        if (top !== null) {
            top = top.bottom;
        }
        if (bottom !== null) {
            bottom = bottom.top;
        }

        return [top, bottom]; // Upper and lower bounds (can be null)
    },

    /**
     * Get the next element in the container or return false
     * TODO very complex for such a simple function. Must be a better way
     *
     * @param {object} ui jQuery ui object
     * @param {number} offset
     *
     */
    nextElement: function(ui, offSet) {

        var parent = $(ui.element).parents('.day_container');

        var emap = $.map($(parent).find('.entry'), _.bind(function(el) {
            return {
                top: this.topPosition(el),
                el: el
            };
        }, this));

        var sorted = _.sortBy(emap, function(i) {
            return i.top;
        });

        // Return any items with a larger top offset than the current el
        var matches = _.filter(sorted, function(i) {
            return i.top > parseInt(offSet, this.RADIX);
        });

        return (matches.length > 0) ? matches[0].el : false;
    },

    previousElement: function(ui, offSet) {
        var parent = $(ui.element).parents('.day_container');

        var emap = $.map($(parent).find('.entry'), _.bind(function(el) {
            // Exclude current entry from list
            if($(el).data('model') != $(ui.element).data('model')) {
                return {
                    top: this.topPosition(el),
                    el: el
                };
            }
        }, this));

        var sorted = _.sortBy(emap, function(i) {
            return i.top;
        });

        // Return any items with a smaller top offset than the current el
        var matches = _.filter(sorted, function(i) {
            return i.top < parseInt(offSet, this.RADIX);
        });

        return (matches.length > 0) ? matches[matches.length - 1].el : false;
    },

    /**
     * @param {number} offset
     * @param {number} nextOffset
     * @return {number} maximum height for an element
     *
     */
    maxHeightForElement: function(offset, nextOffset) {
        return (nextOffset - offset) - 1;
    },

    /**
     * Restrict the size of an entry when using the resize event
     * @param {object} ui jQuery ui object
     */
    restrictSize: function(ui) {

        var offset         = $(ui.element).css('top'),
            originalOffset = ui.originalPosition.top,
            nextEl         = this.nextElement(ui, offset),
            prevEl         = this.previousElement(ui, originalOffset);

        // Resize down
        if (nextEl && this.topPosition(ui.element) == ui.originalPosition.top) {

            var nextOffset = this.topPosition(nextEl),
                currentOffset = this.topPosition(ui.element),
                maxheight = this.maxHeightForElement(currentOffset, nextOffset);

            ui.size.height = ui.size.height > maxheight ? maxheight : ui.size.height;

            if (ui.size.height === maxheight) {
                $(ui.element).height(ui.size.height + 'px');
            }
        }

        // Resize Up
        if(this.topPosition(ui.element) < ui.originalPosition.top) {

            var currentOffset  = this.topPosition(ui.element),
                ceiling        = this.topPosition(prevEl) + $(prevEl).height() + 1,
                maxheight      = $(ui.element).height() + (currentOffset - ceiling),
                originalBottom = ui.originalPosition.top + ui.originalSize.height;

            ui.size.height = ui.size.height > maxheight ? maxheight : ui.size.height;

            if (ui.size.height === maxheight) {
                $(ui.element).css('top', ceiling);
                ui.size.height = originalBottom - ceiling;
            }
        }
    },

    /**
     * Splits a moment string into HH:mm, ignoring time zone
     *
     * @param {string} t_string
     * @return {string} "HH:mm"
     */
    splitTimeString: function(t_string) {

        var a = t_string.split('T'),
            b = a[1].split(':'),
            c = [b[0], b[1]].join(':');

        return c;
    },

    /**
     * Show the current time on the time entry
     *
     * @param [Object] Backbone.js model
     */
    showCurrentTime: function(element, model) {

        var started = model.get('started_at'),
            ended   = model.get('ended_at');

        var start = this.splitTimeString(started),
            end   = this.splitTimeString(ended);

        $(element).find('.time_indicator').html(start + "-" + end).show();
    },

    /**
     *
     * Shared method. Shows tool tips when model
     * gets really small. Gives the user acess to
     * edit and delete functions by showing a tooltip menu
     *
     * @param [] el
     * @param [Object] model
     */
    showToolTips: function(el, model) {

        var that = this;

        $(el).on('hover', function(event) {
            that.showCurrentTime(this, model);
            if ($(this.children[0]).hasClass('minimize-full')) {
                $(this.children[0]).find('.tooltip').show();
            }
        }).mouseleave(function(e) {
            $('.tooltip, .time_indicator').hide();
        });
    },

    /**
     * Ensure that if the element gets too small we hide the text
     * to prevent things looking messy. Used in timing and team
     * timing views
     *
     * @param {object} el jQuery element el
     */
    onResize: function(el) {

        var h = el.removeClass('minimize minimize-half minimize-full')
                  .outerHeight();

        if (h < 30) {
            el.addClass('minimize-full');
        } else if (h < 50) {
            el.addClass('minimize-half');
        } else if (h < 70) {
            el.addClass('minimize');
        }
    },

    /**
     * Used to reverse start and end params if the user swipes
     * backwards (i.e a reverse swipe)
     *
     */
    sortParams: function(start, end) {

        var a, b;

        if (start < end) {
            a = start;
            b = end;
        } else {
            a = end;
            b = start;
        }
        return [a, b];
    },

    /**
     * Ghost div expands upwards
     *
     */
    ghostUp: function(ghost, current, initial, upper, lower, res) {

        // Disable reverse ghosting on ipad
        if (Track.iPad()) {
            return;
        } else {
            // Reverse ghosting
            if (!upper) {
                ghost.css('top', (initial - res) + "px");
                ghost.height(res);
            } else {
                if (current > upper) {
                    ghost.css('top', (initial - res) + "px");
                    ghost.height(res);
                } else {
                    ghost.css('top', (upper + 1));
                }
            }
        }
    },

    /**
     * Ghost div expands downward
     *
     */
    ghostDown: function(ghost, current, initial, upper, lower, res) {
        if (lower === null) {
            // Here there are no bounding objects so just resize to mouse position
            ghost.height(res);
        } else {
            if (current < lower) {
                ghost.height(res);
            } else {
                // Here we've overshot the element so make it as big as possible
                var maxHeight = (lower - initial) - 1;
                ghost.height(maxHeight);
            }
        }
    },

    /**
     * Ensures that ghost div does not overlap existing entries
     *
     * @param {object} ghost ghost div element
     * @param {number} current current position
     * @param {number} initial initial position
     * @param {number} upper upper bound @param {number} lower lower bound
     * @param {number} res
     *
     * @example track.lib.ensureGhostBounds.apply(this, args);
     */
    ensureGhostBounds: function(ghost, current, initial, upper, lower, res) {

        if (current < initial) {
            // user is swiping/moving upwards
            // TODO prevent swipe for ip and also ensure that time indicator
            // doesn't show
            track.lib.ghostUp.apply(this, arguments);
        } else {
            // user is swiping/moving downwards
            track.lib.ghostDown.apply(this, arguments);
        }
    },

    /**
     * Fix z-index issue with calendar overlay
     *
     */
    zIndexFix: function() {

        $('#select_calendar').click(function() {
            $('.time-editor').remove();
            var elements = ['#inner_timing_grid div',
                            '#title_grid div',
                            '#title_grid div'];
            _.each(elements, function(el) {
                $(el).css('z-index', 0);
            });
        });
    }
};
