require 'digest/md5'

class Chargify::WebhooksController < ApplicationController


  # Disable protect_from_forgery
  protect_from_forgery :except => :hook


  # Callbacks
  before_filter :verify, :only => :dispatch


  # Vars
  EVENTS = %w[ test signup_success signup_failure renewal_success renewal_failure payment_success payment_failure billing_date_change subscription_state_change subscription_product_change ].freeze


  #
  # initial Dispatch method that calls the required action.
  def hook
    event = sanitize_event(params[:event])

    unless EVENTS.include? event
      render :json => ['respone' => 'fail'].to_json, :status => 404 and return
    end

    begin
      convert_payload
      self.send event
    rescue Exception => e
      render :json => ['respone' => 'fail'].to_json, :status => 422 and return
    end
  end


  def test
    Rails.logger.debug "Chargify Webhook test!"
    render :json => ['respone' => 'ok'].to_json, :status => 200
  end


  def signup_success
    Account.update_from_webhook_callback(@subscription.id)
    render :json => ['respone' => 'ok'].to_json, :status => 200
  end


  def signup_failure
    render :json => ['respone' => 'ok'].to_json, :status => 200
  end


  def renewal_success
    Account.update_from_webhook_callback(@subscription.id)
    render :json => ['respone' => 'ok'].to_json, :status => 200
  end


  def renewal_failure
    Account.update_from_webhook_callback(@subscription.id)
    render :json => ['respone' => 'ok'].to_json, :status => 200
  end


  def payment_success
    Account.update_from_webhook_callback(@subscription.id)
    render :json => ['respone' => 'ok'].to_json, :status => 200
  end


  def payment_failure
    Account.update_from_webhook_callback(@subscription.id)
    render :json => ['respone' => 'ok'].to_json, :status => 200
  end


  def billing_date_change

    render :json => ['respone' => 'ok'].to_json, :status => 200
  end


  def subscription_state_change
    Account.update_from_webhook_callback(@subscription.id)
    render :json => ['respone' => 'ok'].to_json, :status => 200
  end


  def subscription_product_change
    Account.update_from_webhook_callback(@subscription.id)
    render :json => ['respone' => 'ok'].to_json, :status => 200
  end


  protected

  
  def verify
    if params[:signature].nil?
      params[:signature] = request.headers["HTTP_X_CHARGIFY_WEBHOOK_SIGNATURE"]
    end

    unless MD5::hexdigest(APP_CONFIG['chargify']['shared_key'] + request.raw_post) == params[:signature]
      render :json => ['respone' => 'fail'].to_json, :status => :forbidden
    end
  end


  def convert_payload
    if params[:payload].has_key? :transaction
      @transaction = Chargify::Transaction.new params[:payload][:transaction]
    end

    if params[:payload].has_key? :subscription
      @subscription = Chargify::Subscription.new params[:payload][:subscription]
    end
  end

  def sanitize_event(event)
    EVENTS.include?(event) ? event : nil
  end
  

end
