class DashboardsController < ToolApplicationController


  # Callbacks
  skip_before_filter :check_for_suspended_account


  def index
    authorize current_user, :read?
    if @account.component_enabled?(1)
      @my_entries = Entry.user_entries_by_date(current_user.id, (Time.now.in_time_zone.to_date - 1.day), (Time.now.in_time_zone + 4.days).to_date)
      @my_alerts = Entry.where(["entries.user_id = ?", current_user.id]).includes([:project]).limit(6).order("entries.updated_at DESC")
    end

    if @account.component_enabled?(2)
      @cal = Calendar.new(params, 6)
      @tracked_timing = Timing.for_period(current_user.id, @cal.start_date, @cal.end_date, true)
    end

    if @account.component_enabled?(4) && has_permission?('account_holder || administrator')
      @cal = Calendar.new({})
      @cal.set_start_end_end_of_month
      @totals = Project.payment_prediction_totals(@account, {}, @cal.start_date, @cal.end_date)

      @number_with_payment_expected = Project.number_with_payment_expected_for_period(@account, @cal.start_date, @cal.end_date)
      @number_with_invoice_raised = Project.number_with_payment_expected_for_period_with_raised_invoice(@account, @cal.start_date, @cal.end_date)
    end

    respond_to do |format|
      format.html
    end
  end
end

