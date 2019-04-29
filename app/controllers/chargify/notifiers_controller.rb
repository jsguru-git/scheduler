class Chargify::NotifiersController < FrontApplicationController

  #
  # action called by chargify to confirm subscripton is created
  def confirmation
    @account = Account.find(params[:account_id])

    respond_to do |format|
      # coming from after trial signup
      @account.sync_with_chargify

      if @account.first_login?
        format.html { redirect_to root_url(:subdomain => @account.site_address) }
      else
        format.html { redirect_to root_url(:subdomain => @account.site_address) + 'account_settings' }
      end
    end

  end


  #
  # User redirected to here after update of CC details on hosted chargify pages.
  def confirmation_update
    @account = Account.find(params[:account_id])

    respond_to do |format|
      @account.sync_with_chargify
      format.html { redirect_to root_url(:subdomain => @account.site_address) + 'account_settings/payment_details?updated=1' }
    end
  end


end
