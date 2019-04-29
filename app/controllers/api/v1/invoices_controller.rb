class Api::V1::InvoicesController < Api::V1::ApplicationController

  respond_to :json

  before_filter :parse_date_params
  before_filter :default_filters

  DEFAULT_DUE_END_DATE = 30.days.from_now

  # Public: Returns a list of invoices for an Account.
  #
  # Endpoint: GET /api/v1/invoices.json
  #
  # start_date - Date to filter from. (Default: 1 year ago)
  # end_date   - Date to filter to.   (Default: now)
  #
  # Returns an Array
  def index
    @invoices = @account_invoices.where(invoices: { created_at: @start_date...@end_date })
  end


  # Public: Returns a list of invoices for an Account.
  #
  # Endpoint: GET /api/v1/invoices/{invoice_id}.json
  #
  # Returns an Invoice
  def show
    @invoice = @account_invoices.where(id: params[:id])
  end

  # Public: Returns a list of Invoices due
  #
  # Endpoint: GET /api/v1/invoices/due.json
  #
  # start_date - Date to filter from. (Default: 1 year ago)
  # end_date   - Date to filter to.   (Default: 30 days from now)
  #
  # Returns an Array
  def due
    @invoices = @account_invoices.where(invoices: { due_on_date: @start_date...@end_date })
  end

  # Public: Returns a list of Invoices expected
  #
  # Endpoint: GET /api/v1/invoices/expected.json
  #
  # start_date - Date to filter from. (Default: 1 year ago)
  # end_date   - Date to filter to.   (Default: 30 days from now)
  #
  # Returns an Array
  def expected
    @invoices = @account_invoices.joins(:payment_profiles)
                                 .where(payment_profiles: { expected_payment_date: @start_date...@end_date })
    respond_to do |format|
      format.json { render json: @invoices.to_json(include: :payment_profiles) }
    end
  end

  # Public: Returns a list of expected invoicing
  #
  # Endpoint: GET /api/v1/invoices/payment_predictions.json
  #
  # start_date - Date to filter from. (Default: 1 year ago)
  # end_date   - Date to filter to.   (Default: 30 days from now)
  #
  # Returns an Array
  def payment_predictions
    @results = Project.payment_prediction_results(@account, params, @start_date, @end_date)
    @totals = Project.payment_prediction_totals(@account, params, @start_date, @end_date)
  end

  # Public: Returns allocated amount for time period
  #
  # Endpoint: GET /api/v1/invoices/allocated.json
  def allocated
    @amount = InvoiceUsage.amount_cents_allocated_for_period(Account.find_by_site_address(request.subdomain), @start_date, @end_date)
  end

  protected

  def parse_date_params
    params[:action] == 'due' ? default_end_date = DEFAULT_DUE_END_DATE : default_end_date = DEFAULT_END_DATE
    @end_date = (params[:end_date] || default_end_date).to_datetime
    @start_date = (params[:start_date] || DEFAULT_START_DATE).to_datetime
  end

  def default_filters
    @account_invoices = Invoice.joins(project: :account)
                               .where(accounts: { site_address: request.subdomain })
    @account = Account.find_by_site_address(request.subdomain)
  end

end