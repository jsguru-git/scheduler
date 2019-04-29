class QuoteDefaultSectionsController < ToolApplicationController
  
  # SSL
  skip_before_filter :ensure_correct_protocol
  skip_after_filter :verify_authorized # This controller is not subject to Pundit policies
  force_ssl

  # ACL
  access_rule 'account_holder || administrator'
  
  def create
    @quote_default_section = @account.quote_default_sections.create
    
    respond_to do |format|
      format.js
      format.html { redirect_to quote_settings_path }
    end
  end
  
  def update
    @quote_default_section = @account.quote_default_sections.find(params[:id])
    
    respond_to do |format|
      if @quote_default_section.update_attributes(params[:quote_default_section])
        format.js
        format.html { redirect_to quote_settings_path }
      else
        format.js
        format.html {
          flash[:alert] = @quote_default_section.errors.full_messages.first
          redirect_to quote_settings_path
        }
      end
    end
  end
  
  def destroy
    @quote_default_section = @account.quote_default_sections.find(params[:id])
    @quote_default_section.destroy
    
    respond_to do |format|
      format.js
      format.html { redirect_to quote_settings_path }
    end
  end
  
  def sort
    if params[:quote_default_section].present?
      params[:quote_default_section].each_with_index do |id, index|
        @account.quote_default_sections.update_all({position: index+1}, {id: id})
      end
    end

    render nothing: true
  end
  
end
