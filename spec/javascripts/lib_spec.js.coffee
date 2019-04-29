# Library function tests
#
describe "Lib", ->

  describe "logicalNegation", ->
    it "should return the logical complment of a boolean value", ->
      a = track.lib.logicalNegation(true)
      b = track.lib.logicalNegation(false)      
      expect(a).toEqual(false)
      expect(b).toEqual(true)

  describe "formatZeroValue", ->
    it "should normalize values that start with 0", ->
      a = track.lib.formatZeroValue("08")
      b = track.lib.formatZeroValue("8")
      expect(a).toEqual("8")
      expect(b).toEqual("8")
      
  describe "extractHoursMinutes", ->
    it "should return array of hours and minutes", ->
      t1 = "Tue Oct 30 2012 08:00:00"
      t2 = "2012-10-31T08:20:00-05:00"
      a = track.lib.extractHoursMinutes(t1)
      b = track.lib.extractHoursMinutes(t2)
      expect(a).toEqual(['08', '00'])
      expect(b).toEqual(['08', '20'])
      
  describe "hoursMinutesFromString", ->
    it "should return an integer array", ->
       t = track.lib.hmFromString("Tue Oct 30 2012 08:20:00")
       expect(t).toEqual([8, 20])

  describe "splitTimeString", ->
    it "should return HH:mm ignoring timezone", ->
      candidate = "2012-12-10T13:58:00+08:00"
      result    = track.lib.splitTimeString(candidate)
      expect(result).toEqual("13:58")

  # describe "timeWithoutZone", ->
  #   it "should return a time string in correct format", ->
  #     date = "Wed Feb 06 2013 10:35:37 GMT+0500 (GMT)"
  #     result = track.lib.timeWithoutZone(date)
  #     expect(result).toEqual("2013-02-06T10:35")

  #   it "should handle multiple date formats correctly", ->
  #     a = "Wed Feb 06 2013 10:35:37 GMT+0300 (GMT)"
  #     b = "2013-02-06 10:35:37"
  #     c = track.lib.timeWithoutZone(a)
  #     d = track.lib.timeWithoutZone(b)
  #     expect(c).toEqual("2013-02-06T10:35")
  #     expect(d).toEqual("2013-02-06T10:35")
      
  describe "sortElementsByTopOffset", ->
    it "should return an array of sorted elements", ->
      unsorted = [{top: 600, bottom:800},
                  {top: 200, bottom: 400}]        
      sorted   = [{top: 200, bottom:400},
                  {top: 600, bottom: 800}]           
      result = track.lib.sortByTopOffset(unsorted)
      expect(result).toEqual(sorted)
      expect(result[0]['top']).toEqual(200)

    it "should return the data unchanged if elements are already sorted", ->
      sorted   = [{top: 100, bottom:200},
                  {top: 400, bottom: 500}]        
      result = track.lib.sortByTopOffset(sorted)
      expect(result).toEqual(sorted)
        
