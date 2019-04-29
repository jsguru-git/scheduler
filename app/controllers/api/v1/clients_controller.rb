class Api::V1::ClientsController < Api::V1::ApplicationController

  respond_to :json

  before_filter :parse_date_params
  before_filter :default_filters

  # Public: Returns a list of Clients for an Account.
  #
  # Endpoint: GET /api/v1/clients.json
  #
  # Returns an Array
  def index
    @clients = @account_clients
  end

  # Public: Returns a Client for an Account.
  #
  # Endpoint: GET /api/v1/clients/{client_id}.json
  #
  # Returns an Invoice
  def show
    @client = @account_clients.where(id: params[:id])
  end

  # Public: Returns a list of a Client's profit and loss account
  #
  # Endpoint: GET /api/v1/clients/{id}/profit_and_loss.json
  #
  # start_date - Date to filter from. (Default: 1 year ago)
  # end_date   - Date to filter to.   (Default: 30 days from now)
  #
  # Returns an Array
  def profit_and_loss
    @client = @account_clients.find(params[:id])
  end

  protected

  def parse_date_params
    @end_date = (params[:end_date] || DEFAULT_END_DATE).to_datetime
    @start_date = (params[:start_date] || DEFAULT_START_DATE).to_datetime
  end

  def default_filters
    @account_clients = Client.joins(:account)
                             .where(accounts: { site_address: request.subdomain })
  end

end