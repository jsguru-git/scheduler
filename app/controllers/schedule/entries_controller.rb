class Schedule::EntriesController < ToolApplicationController


  # Callbacks
  before_filter :check_schedule_is_active, :breadcrumbs

  def index
    @cal = Calendar.new(params)
    authorize Entry, :read?
    params[:team_id] ||= current_user.teams.first.id if current_user.teams.present?
    respond_to do |format|
      format.html
    end
  end


  def lead_time
    @lead_time_users =  Entry.user_lead_times(@account, params)
    authorize Entry, :report?

    respond_to do |format|
      format.html
    end
  end

private

  def breadcrumbs
    @breadcrumbs.add_breadcrumb('Dashboard', root_path)
    @breadcrumbs.add_breadcrumb('Time', track_timings_path(:user_view => current_user.id))
  end

end

