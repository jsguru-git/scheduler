class Reports::ProjectsController < ToolApplicationController

  # Callbacks
  before_filter :breadcrumbs, :report_permissions
  skip_after_filter :verify_authorized
  
  # Project overview report
  def overview
    @projects = Project.select('projects.*')
                       .select('SUM(payment_profiles.expected_cost_cents) AS budget')
                       .select('COUNT(project_comments.id) AS comments')
                       .where(account_id: @account.id).where(event_type: 0).where(archived: false)
                       .where(project_status: 'in_progress')
                       .where(clients: { internal: false })
                       .joins('LEFT OUTER JOIN phases ON phases.id = projects.phase_id')
                       .joins('LEFT OUTER JOIN users project_manager ON projects.project_manager_id = project_manager.id')
                       .joins('LEFT OUTER JOIN users business_owner ON projects.business_owner_id = business_owner.id')
                       .joins('LEFT OUTER JOIN clients ON projects.client_id = clients.id')
                       .joins('LEFT OUTER JOIN payment_profiles ON payment_profiles.project_id = projects.id')
                       .joins('LEFT OUTER JOIN project_comments ON project_comments.project_id = projects.id')
                       .order(sanitized_sort_params(params[:sort], params[:direction]))
                       .group('projects.id')

    @projects = @projects.where(client_id: params[:client_id]) if params[:client_id].present?
    @projects = @projects.where(id: params[:project_id]) if params[:project_id].present?
    @projects = @projects.where(project_manager_id: params[:project_manager_id]) if params[:project_manager_id].present?

    @projects_paginated = @projects.paginate(:page => params[:page], :per_page => 40)

    @project_managers = @projects.map(&:project_manager).uniq.compact.sort_by(&:firstname)

    respond_to do |format|
      format.html
    end
  end

  def forecast
    @projects = @account.projects.where(archived: false)
                                 .where(clients: { internal: false, archived: false })
                                 .where(project_status: 'in_progress')
                                 .joins(:client)
                                 .order('clients.name')

    @number_of_months = 6
    @results = []
    (0...@number_of_months).to_a.collect{ |i| @results << Project.payment_prediction_results(@account, params, (Date.today + i.months).beginning_of_month, (Date.today + i.months).end_of_month) }

    @months = []
    (0...@number_of_months).to_a.collect{ |i| @months << (Date.today + i.months).strftime('%B') }
  end  
  
  # Percentage time spent on project report
  def percentage_time_spent
    @cal = Calendar.new(params)
    @cal.set_start_end_end_of_month if params[:start_date].blank?
    params[:project_id] ||= @account.projects.name_ordered.first.id.to_s
    
    @project = @account.projects.find(params[:project_id])
    
    @teams = @account.teams.order('name')
    
    respond_to do |format|
      format.html
    end
  end

  # Client utilisation report
  def project_utilisation
    @time_filters = { start_date: (params[:start_date] || 1.month.ago), end_date: (params[:end_date] || Date.today) }
    if params[:view].blank? || params[:view] == 'clients'
      @clients = @account.clients.not_internal.includes(:projects).paginate(:page => params[:page], :per_page => APP_CONFIG['pagination']['site_pagination_per_page'])
    else
      @teams = @account.teams
      @teams = @teams.where(id: params[:team_id]) if params[:team_id].present? && params[:page].blank?
      @teams = @teams.paginate(:page => params[:page], :per_page => 5)
      @client_rates = []
      @account.clients.each do |client|
        @client_rates << { client: client.name, avg_rate: client.avg_rate_card_amount_cents }
      end
    end

    if params[:client_id].present? && @clients.present?
      @clients = @clients.where(id: params[:client_id])
    end

    @breadcrumbs.add_breadcrumb('Client Utilisation', nil)
  end
  
  
  def qa_stats
    @project = @account.projects.find(params[:id])
    @qa_stats = @project.qa_stats.order('qa_stats.created_at DESC').paginate(per_page: 100, page: params[:page])
    @priority_headings  = QaStat.get_all_column_headings_for(@qa_stats, :priority)
    @status_headings    = QaStat.get_all_column_headings_for(@qa_stats, :status)
    
    respond_to do |format|
      format.html
    end
  end
  
  
private

  def sanitized_sort_params(field, order)
    acceptable_sort_params = /^(clients|projects|project_manager|business_owner|budget|comments|phases).?(name|firstname|current_rag_status|percentage_complete)?$/
    acceptable_sort_directions = /^(de|a)sc$/

    if field =~ acceptable_sort_params && order =~ acceptable_sort_directions
      "#{ field } #{ order }"
    else
      ''
    end
  end

  def breadcrumbs
    @breadcrumbs.add_breadcrumb('Dashboard', root_path)
    @breadcrumbs.add_breadcrumb('Reports', reports_path)
  end
  
end
