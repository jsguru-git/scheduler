class ProfileAdmin::AccountsController < ProfileAdmin::ProfileAdminApplicationController


  def index
    search_var = params[:subdomain] + '%' if params[:subdomain].present?
    @accounts = Account.where([params[:subdomain].blank? ? '1=1' : 'site_address LIKE ?', search_var]).order('accounts.id DESC').paginate(:per_page =>20, :page => params[:page])

    respond_to do |format|
      format.html
    end
  end


end
