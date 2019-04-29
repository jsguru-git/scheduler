class Track::TimingsController < ToolApplicationController


  before_filter :check_track_is_active, :breadcrumbs


  def index
    @cal = Calendar.new(params, 6)

    if has_permission?('account_holder || administrator')
      params[:user_id] ||= current_user.id.to_s
      params[:team_id] ||= current_user.teams.first.id if current_user.teams.present?
      @user = @account.users.find(params[:user_id])
      @team = params[:team_id] ? @account.teams.find(params[:team_id]) : @account.teams.first
    else
      @user = @account.users.find(current_user.id)
    end
    authorize @user.timings, :read?
    respond_to do |format|
      format.html
    end
  end


  def submit_time
    if has_permission?('account_holder || administrator')
      @user = @account.users.find(params[:user_id])
    else
      @user = current_user
      raise ActiveRecord::RecordNotFound if @user.id != params[:user_id].to_i
    end
    authorize @user.timings, :update?
    @date = Date.parse(params[:date])
    updated = Timing.submit_entries_for_user_and_day(@user.id, @date)

    if updated == 0
      flash[:notice] = 'Time has been successfully submitted'
    elsif updated == 1
      flash[:alert] = 'Please make sure all time entries have a task for the given day'
    else
      flash[:alert] = 'No completed time entries have been found for the given day'
    end

    respond_to do |format|
      @cal = Calendar.new(params, 6)
      format.html { redirect_to track_timings_path(:user_view => params[:user_view],
                                                   :start_date => @cal.start_date,
                                                   :user_id => @user.id) }
    end
  end


  # POST /track/timings/shift_calendar
  #
  def shift_calendar
    authorize Timing, :read?
    opts = Timings.get_shift_params(params)
    redirect_to track_timings_path(opts)
  end


  def submitted_time_report
    @cal = Calendar.new(params, 6)
    @projects = @account.projects.where("projects.project_status != ?", :closed)

    if params[:start_date].blank? && params[:start_date].blank?
      @cal.start_date = (@cal.start_date - 1.week).beginning_of_week
      @cal.end_date = @cal.start_date.end_of_week
    end

    if has_permission?('account_holder || administrator')
      params[:user_id] ||= current_user.id.to_s
      @user = @account.users.find(params[:user_id])
    else
      @user = @account.users.find(current_user.id)
    end

    @timings = Timing.submitted_for_period(@user.id, @cal.start_date, @cal.end_date, true)
    @timings = @timings.where(project_id: params[:project_id]) if params[:project_id].present?
    authorize @timings, :read?

    respond_to do |format|
      format.html
      format.csv {
        reporter = Reporter::TimeReport.new(@user.id, { project_id: params[:project_id] })
        send_data reporter.to_csv(@cal.start_date, @cal.end_date)
      }
    end
  end
  
private

  def breadcrumbs
    @breadcrumbs.add_breadcrumb('Dashboard', root_path)
    @breadcrumbs.add_breadcrumb('Time', track_timings_path(:user_view => current_user.id))
  end

end

