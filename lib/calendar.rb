class Calendar

  attr_accessor :start_date, :end_date

  def initialize(params, default_end_from_start = 20)
    self.start_date_from_param_or_default(params[:start_date])
    self.end_date_from_param_or_default(params[:end_date], default_end_from_start)
  end


  # Returns the date of last sunday
  def self.start_of_current_week
    t = Time.now.in_time_zone
    (t.beginning_of_week).to_date
  end
  
  
  # Set start and end of month
  def set_start_end_end_of_month
    t = Time.now.in_time_zone
    @start_date = t.beginning_of_month.to_date
    @end_date = t.end_of_month.to_date
  end
  
  
protected

	# Parse the date thats been passed in or get the start of the week
  def start_date_from_param_or_default(start_date)
    if start_date.blank?
      @start_date = Calendar.start_of_current_week
    else
      @start_date = Date.parse(start_date) rescue Calendar.start_of_current_week
    end
  end

  # Parse end date and if blank return 3 weeks in the future from start
  def end_date_from_param_or_default(end_date, default_end_from_start)
    if start_date.blank?
      @end_date = @start_date + default_end_from_start.days
    else
      @end_date = Date.parse(end_date) rescue @start_date + default_end_from_start.days
    end
  end
end

