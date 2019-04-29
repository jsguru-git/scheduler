# global console _ Track track log moment
#
#
# TODO We need to normalize ALL date strings in this app as they are causing a lot
# of headaches. Write a function to normalize all time strings and always use it
# when parsing date strings in this application.

dec = (n) -> n - 1
inc = (n) -> n + 1

# Parse int and set radix to base 10
toInt = (n) -> parseInt n, 10

track.ns "util"

track.util.log = ->
  log.history = log.history or []
  log.history.push arguments
  if @console
    console.log Array::slice.call(arguments)

window.log = track.util.log

###
# Scrolls the grid to a specific time. I.e to scroll to 8am
# track.util.scrollTo(8);
###
track.util.scrollTo = (hour) ->
  distance = 60 * hour
  $("#track_calendar").scrollTop(distance)

# Show a time indicator for ghost div elements
track.util.showIndicator = (start, current) ->
  return if Track.iPad() and (current < start)
  $(".ghost .time_indicator").show()
  a = track.util.convertOffsetToTime(start)
  b = track.util.convertOffsetToTime(current)
  if current < start
    $(".ghost .time_indicator").html b + " : " + a
  else
    $(".ghost .time_indicator").html a + " : " + b

###
# Parses working day start time and scrolls down to the correct
# point in the grid
###
track.util.scrollToDayStart = ->
  start = $("#track_calendar_container").data("workingDayStartTime")
  time = start.split(" ")[1].split(":")[0]
  track.util.scrollTo toInt(time)

track.util.round = (n) ->
  Math.round n

###
# Gets a date or timestamp in a specific format
# @param attr
# @param format
###
track.util.format = (attr, format) ->
  moment(attr).format format

# Split time and parse hours and minutes to calcuate offset
# @param {string} t
track.util.calculateOffset = (t) ->
  if (t.split(' ').length) is 1
    time = t.split('T')[1].split(':').slice(0,2).join(':')
  else
    s = t.split(" ")
    time = s[4]

  parts   = _.map(time.split(':'), (p) -> toInt(p))
  hours   = parts[0]
  minutes = parts[1]
  ((hours * 60) + minutes)

###
# Given a time string such as "02:29" convert to a pixel offset
# @param {string} t
###
track.util.timeToPixelOffset = (t) ->
  hours = moment(t).hours()
  minutes = moment(t).minutes()
  result = ((hours * 60) + minutes)
  result

###
# Rounds a position p to the nearest n
###
track.util.roundToNearest = (p, n) ->
  n = (if typeof n is "undefined" then 10 else n)
  (Math.round(p / n)) * n

###
# Calculates the y offset from a click event
# to give a time in minutes
#
# @returns Integer a click position relative to the parent div
###
track.util.timeFromClick = (event) ->
  parentOffset = $(event.currentTarget).parent().offset()
  if event.originalEvent and event.originalEvent.touches
    if event.originalEvent.touches.length > 0
       y = event.originalEvent.touches[0].pageY
    else
       y = event.originalEvent.changedTouches[0].pageY
  else
    y = event.pageY
  Math.round(y - parentOffset.top)

track.util.exactOffset = track.util.timeFromClick

track.util.relativeOffset = (type, el, offset) ->
  parentOffset = $(el).parent().offset()
  if type is "x"
    Math.round(offset - parentOffset.left)
  else
    Math.round(offset - parentOffset.top)

###
# Extracts the date from a .day_container column
#
# @returns {string}
###
track.util.getColumnDate = (column) ->
  $(column).data "columnDate"

track.util.recurUntil = (n, target) ->
  if n is target
    n
  else
    track.util.recurUntil dec(n), target

###
# Pads out an int so that 1 becomes 01 etc
#
# @returns {string}
###
track.util.padInteger = (n) ->
  return ("0" + n)  if n < 10
  n.toString()

###
# Use recursion to ensure that height ends in a 4 or a 9
#
# @param {number} h the height of a time entry
###
track.util.ensureSafeHeight = (h) ->
  r = h % 10
  if r is 4 or r is 9
    h
  else
    # Recur
    @ensureSafeHeight dec(h)

###
# Each pixel on the grid represents 1 minute.
# Grid starts at 00:00
#
# A pixel offset of 60 represents a time at 01:00
# A pixel offset of 89 represents a time at 01:29
###
track.util.convertOffsetToTime = (offset) ->
  hours = track.util.padInteger(Math.floor(offset / 60))
  minutes = track.util.padInteger(offset % 60)
  hours + ":" + minutes

track.util.endTime = (offset, height) ->
  value = offset + height
  track.util.convertOffsetToTime value

###
# Used to merge together a time (i.e 02:29) and a date (i.e 2012-09-09)
# @param String time
# @param String date
#
# @returns Date
###
track.util.fullDate = (time, date) ->
  format = moment(date).format("MMMM D YYYY")
  t = format + " " + time
  moment(t, "MMMM D YYYY hh:mm").toString()

###
# Given a full date, returns a time string i.e 12:30
# @return {string}
###
track.util.timeFromDate = (date) ->
  date_string = date.toString()
  if(date_string.split(' ').length is 1)
  then date_string.split('T')[1].split(':').slice(0,2).join(':')
  else moment(date).format("HH:mm")

# ES5 only -> handle annoying dates better
track.util.parseDateSegments = (date_string) ->
  parts = date_string.split(/[^0-9]/)
  args = (_.map(parts, (i) -> toInt(i)))
  new (Date.bind.apply(Date, [null].concat(args)))

###
# Return the height of an element given a start and end time
###
track.util.entryHeight = (start, end) ->
  moment(end).diff(start, "minutes")

###
# Returns array pair i.e ["09:00", "12:30"]
###
track.util.getPair = (start, inc) ->
  timeFormat = "HH:mm"
  end = moment(start, timeFormat).add("minutes", dec(inc))
  _.map [moment(start, timeFormat), end], (t) ->
    t.format(timeFormat).toString()

###
# Maps out time increments
#
# @param {string} start the start time in format "09:00"
# @param {number} total the total number of entries
# @param {number} inc the time increment in minutes
###
track.util.timeIncrementMap = (start, total, inc) ->
  _.map _.range(total), (iter) ->
    t = moment(start, "HH:mm").add("minutes", inc * iter)
    t.format("HH:mm").toString()

# A single entry gets divided into two parts and a break
track.util.divideSingle = ->
  timeForEntry = (Track.workingDay() - 60) / 2
  m = track.util.timeIncrementMap(Track.dayStart(), 2, timeForEntry)
  _.map m, _.bind((iter) ->
    track.util.getPair iter, timeForEntry
  , this)

## Old function. Removes an hour for lunch.
## Now going to assume that this comes from the schedule
track.util.dividePairsWithLunchBreak = (count) ->
  lunchBreak = 60 # total break time
  timeForEntry = (Track.workingDay() - lunchBreak) / count
  m = track.util.timeIncrementMap(Track.dayStart(), count, timeForEntry)
  _.map m, _.bind((iter) ->
    track.util.getPair iter, timeForEntry
  , this)

###
# Evenly divide pairs across the grid based on start and end time
# TODO tests
###
track.util.dividePairs = (count) ->
  timeForEntry = (Track.workingDay()) / count
  m = track.util.timeIncrementMap(Track.dayStart(), count, timeForEntry)
  _.map m, _.bind((iter) ->
    track.util.getPair iter, timeForEntry
  , this)

