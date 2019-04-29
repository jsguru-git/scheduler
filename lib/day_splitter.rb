class DaySplitter

  attr_accessor :working_days

  # Public: Create a new instance of DaySplitter
  #
  # working_days - Hash of day/boolean key values
  #
  # Examples
  #
  #   DaySplitter.new({monday: '1', tuesday: '1'... })
  #
  # Returns instance of DaySplitter
  def initialize(working_days = {})
    @working_days = working_days
  end

  # Public: Split days into working week ranges
  #
  # start_date - Date
  # end_date   - Date
  #
  # Returns an Array of Hashes
  def working_day_ranges(start_date, end_date)
    working_days = (start_date..end_date).map { |day| @working_days[day.strftime('%A').downcase.to_sym] == '1' ? day : 'x' }
    split_days = working_days.slice_before('x').to_a
    split_days.each { |array| array.delete('x') }.reject! { |array| array.empty? }
    split_days.map { |array| { start_date: array.first, end_date: array.last } }
  end
end