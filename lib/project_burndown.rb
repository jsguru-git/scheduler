module ProjectBurndown

  def self.burndown_chart_data(timings, total_estimate_minutes)
    h_tracked = {}
    week_no = 1

    timings.each do |timing|
      # Set week var's
      timing_date = timing.started_at.to_date
      start_of_week = timing_date.beginning_of_week
      end_of_week = start_of_week + 6.days

      if h_tracked.has_key?(week_no)
        # Check its the same week and if not, move on to next week
        unless h_tracked[week_no][:start_of_week] == start_of_week

          # Create any empty weeks
          while true
            week_no += 1
            next_start_week = h_tracked[h_tracked.length][:start_of_week] + 7.days
            next_end_week = next_start_week + 6.days
            h_tracked[week_no] = {:start_of_week => next_start_week, :end_of_week => next_end_week, :week_no => week_no, :minutes => 0, :estimate_minutes_left => total_estimate_minutes}

            break if next_start_week == start_of_week
          end

          h_tracked[week_no] = {:start_of_week => start_of_week, :end_of_week => end_of_week, :week_no => week_no, :minutes => 0, :estimate_minutes_left => total_estimate_minutes}
        end
      else
        h_tracked[week_no] = {:start_of_week => start_of_week, :end_of_week => end_of_week, :week_no => week_no, :minutes => 0, :estimate_minutes_left => total_estimate_minutes}
      end

      total_estimate_minutes -= timing.duration_minutes
      h_tracked[week_no][:minutes] += timing.duration_minutes
      h_tracked[week_no][:estimate_minutes_left] = total_estimate_minutes
    end

    # Loop over all weeks and calculate hours and minutes for display purposes
    h_tracked.each do |key, value|
      estimate_left_in_hours = (value[:estimate_minutes_left].to_f / 60).to_i
      estimate_left_in_minutes = value[:estimate_minutes_left].abs% 60

      tracked_in_hours = (value[:minutes] / 60).to_i
      tracked_in_minutes = value[:minutes]% 60

      value[:tracked_time] = "#{tracked_in_hours} " + (tracked_in_hours == 1 ? 'hour' : 'hours')+" #{tracked_in_minutes} " + (tracked_in_minutes == 1 ? 'min' : 'mins')
      value[:estimate_left] = "#{estimate_left_in_hours} "+ (estimate_left_in_hours == 1 || estimate_left_in_hours == - 1 ? 'hour' : 'hours') + " #{estimate_left_in_minutes} " + (estimate_left_in_minutes == 1 ? 'min' : 'mins')
    end

    return h_tracked
  end
end