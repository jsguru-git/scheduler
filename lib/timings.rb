module Timings

  # Shift a date forward or back by one week
  #
  # fn   - either :+ or :-
  # date - a string date in the format Y-m-d
  # shift_days - number of days to shift by
  #
  # Returns a date in the format Y-m-d
  def self.shift_url(fn, date, shift_days)
    Date.parse(date).send(fn, shift_days.days).strftime("%Y-%m-%d")
  end


  def self.get_shift_params(params)
    if params[:direction].to_sym == :forward
      start = shift_url(:+, params[:start_date], params[:shift_days].to_i)
    else
      start = shift_url(:-, params[:start_date], params[:shift_days].to_i)
    end
    original_params = { :user_id   => params[:user_id], :user_view => params[:user_view] }
    original_params.merge(:start_date => start)
  end

  # Public: Convert a number of minutes to days rounded
  #
  # minutes          - Number of minutes to convert
  # account          - The Account currently being used.
  #                    This is to pull in information about working day duration.
  # decimal_places   - Number of decimal places to round to. (Default: 2)
  #
  # Returns a Decimal
  def self.convert_minutes_to_days(minutes, account, decimal_places = 2)
    (minutes.to_s.to_d / account.account_setting.working_day_duration_minutes).round(decimal_places)
  end
  
  
end
