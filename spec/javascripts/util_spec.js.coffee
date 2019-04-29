# Utility tests
#
describe "Utils", ->
  
  describe "roundToNearest", ->
    it "should round down to 30", ->
      expect(track.util.roundToNearest(34)).toEqual(30)
    it "should round up to 40", ->
      expect(track.util.roundToNearest(36)).toEqual(40)
  
  describe "DateUtils", ->
    it "should format a date string", ->
      d = '2012-09-06 09:52:22 +0000'
      f = 'YYYY-MM-DD'
      expect(track.util.format(d, f)).toEqual('2012-09-06')

  describe "calculateOffset", ->
    it "should calculate the correct position offset", ->
      t1 = "2012-10-31T01:30:00-08:00"
      t2 = "Wed Oct 31 2012 04:00:00"
      t3 = "2012-10-31T01:30:00+02:00"
      expect(track.util.calculateOffset(t1)).toEqual(90)
      expect(track.util.calculateOffset(t2)).toEqual(240)
      expect(track.util.calculateOffset(t3)).toEqual(90)

  describe "ensureSafeHeight", ->
    it "should return a number ending with 4 or 9", ->
      a = 206
      b = 250
      c = 456
      expect(track.util.ensureSafeHeight(a)).toEqual(204)
      expect(track.util.ensureSafeHeight(b)).toEqual(249)
      expect(track.util.ensureSafeHeight(c)).toEqual(454)

  describe "getPair", ->
    it "should return a time pair", ->
      a = track.util.getPair("09:00", 120)
      b = track.util.getPair("15:00", 150)      
      expect(a).toEqual(["09:00", "10:59"])
      expect(b).toEqual(["15:00", "17:29"])      

  describe "Round", ->
    it "should round a number", ->
      result = track.util.round(10.34432)
      expect(result).toEqual(10)

  describe "timeFromDate", ->
    it "should return a time string", ->
      time = "Fri Sep 14 2012 10:16:29"
      expect(track.util.timeFromDate(time)).toEqual("10:16")

  describe "padInteger", ->
    it "should pad an integer less than 10", ->
      expect(track.util.padInteger(9)).toEqual("09")
      
    it "should not pad an integer greater than 9", ->
      expect(track.util.padInteger(10)).toEqual("10")
      expect(track.util.padInteger(14)).toEqual("14")

  describe "convertOffsetToTime", ->
    it "should convert whole number to a time string", ->
      fn = track.util.convertOffsetToTime(60)
      expect(fn).toEqual("01:00")
      
