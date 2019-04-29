class Api::V1::ProjectsController < Api::V1::ApplicationController

  respond_to :json

  before_filter :parse_date_params
  before_filter :default_filters

  # Public: Returns a list of Projects for an Account.
  #
  # Endpoint: GET /api/v1/projects.json
  #
  # start_date - Date to filter from. (Default: 1 year ago)
  # end_date   - Date to filter to.   (Default: now)
  #
  # Returns an Array
  def index
    @projects = @account_projects.where(created_at: @start_date...@end_date)
  end

  # Public: Returns a list of Projects for an Account.
  #
  # Endpoint: GET /api/v1/projects/{project_id}.json
  #
  # Returns a Project
  def show
    @project = @account_projects.where(id: params[:id])
  end

  # Public: Returns a list of Timings for a Project.
  #
  # Endpoint: GET /api/v1/projects/{project_id}/timings.json
  #
  # Returns Array of Timings
  def timings
    @timings = @account_projects.find(params[:id])
                                .timings
                                .where(started_at: @start_date...@end_date)
  end
  
  # Public: Returns a list of Tasks for a Project.
  #
  # Endpoint: GET /api/v1/projects/{project_id}/tasks.json
  #
  # Returns Array of Tasks
  def tasks
    @tasks = @account_projects.find(params[:id])
                              .tasks
  end
  
  # Public: Returns a list of PaymentProfiles for a Project.
  #
  # Endpoint: GET /api/v1/projects/{project_id}/payment_profiles.json
  #
  # Returns Array of PaymentProfiles
  def payment_profiles
    @payment_profiles = @account_projects.find(params[:id])
                                         .payment_profiles
  end

  protected

  def parse_date_params
    @end_date = (params[:end_date] || DEFAULT_END_DATE).to_datetime
    @start_date = (params[:start_date] || DEFAULT_START_DATE).to_datetime
  end

  def default_filters
    @account_projects = Project.joins(:account)
                               .where(accounts: { site_address: request.subdomain })
  end

end