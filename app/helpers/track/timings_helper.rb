module Track::TimingsHelper

  # Checks if the time is submitted for a given user
  def is_time_submitted?(date, user_id)
    Timing.submitted_for_period?(user_id, date.to_datetime, date.end_of_day)
  end


  # Helper that generates a url for the shift calendar functionality in track
  def shift_calendar_link(cal, direction, opts = {})
    options = opts.merge(start_date: cal.start_date, direction: direction)
    if direction == :back
      class_name = "week_link icon-chevron-left"
      id_name    = "week_prev"
    else
      class_name = "week_link icon-chevron-right"
      id_name    = "week_next"
    end
    link_to '',
            shift_calendar_track_timings_path(options),
            method: :post,
            class:  class_name,
            id:     id_name
  end

end

