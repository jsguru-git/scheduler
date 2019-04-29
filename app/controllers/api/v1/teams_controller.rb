class Api::V1::TeamsController < Api::V1::ApplicationController

  respond_to :json

  before_filter :parse_date_params
  before_filter :default_filters

  # Public: Returns a list of Team.
  #
  # Endpoint: GET /api/v1/teams.json
  #
  # Returns ActiveRecord::Relation of Teams
  def index
    @teams = @account_teams
  end

  # Public: Returns details of a Team
  #
  # Endpoint: GET /api/v1/teams/{id}.json
  #
  # Returns a Team
  def show
    @team = @account_teams.find(params[:id])
  end

  # Public: Returns a list of Timings for a Team.
  #
  # Endpoint: GET /api/v1/teams/{team_id}/timings.json
  #
  # Returns ActiveRecord::Relations of Timings
  def entries
    @entries = @account_teams.find(params[:id])
                             .entries
                             .where(end_date: @start_date...@end_date)
                             .order('entries.start_date DESC')
  end

  # Public: Returns a list of Timings for a Team.
  #
  # Endpoint: GET /api/v1/teams/{team_id}/timings.json
  #
  # Returns ActiveRecord::Relation of Timings
  def timings
    @timings = @account_teams.find(params[:id])
                             .timings
                             .where(started_at: @start_date...@end_date)
  end

  protected

  def parse_date_params
    @end_date = (params[:end_date] || DEFAULT_END_DATE).to_datetime
    @start_date = (params[:start_date] || DEFAULT_START_DATE).to_datetime
  end

  def default_filters
    @account_teams = Team.joins(:account)
                         .where(accounts: { site_address: request.subdomain })
  end

end
