class EntriesController < ToolApplicationController

  include Icalendar

  before_filter :date_range

  def index
    authorize Entry, :read?

    respond_to do |format|
      format.ics { render text: ics_file.to_ical }
    end
  end

  protected

  def date_range
    params[:start_date].present? ? @start_date = params[:start_date] : @start_date = Date.today
    params[:end_date].present? ? @end_date = params[:end_date] : @end_date = 8.days.from_now
  end

  def ics_file
    current_user.scheduled_projects_ics.to_ical
  end

end