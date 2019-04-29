class RateCardsController < ToolApplicationController

  # SSL
  skip_before_filter :ensure_correct_protocol
  force_ssl

  before_filter :breadcrumbs

  def index
    @rate_cards = @account.rate_cards.service_type_ordered

    authorize @account, :read?

    respond_to do |format|
      format.html
    end
  end


  def new
    @rate_card = @account.rate_cards.new

    authorize @account, :update?

    respond_to do |format|
      format.html
      format.js
    end
  end


  def create
    @rate_card = @account.rate_cards.new(params[:rate_card])

    authorize @account, :update?

    respond_to do |format|
      if @rate_card.save
        format.html {
          flash[:notice] = "Service has been successfully created"
          redirect_to(rate_cards_path)
        }
        format.js
      else
        format.html {render :action => 'new'}
        format.js {render :action => 'new'}
      end
    end
  end


  def edit
    @rate_card = @account.rate_cards.find(params[:id])

    authorize @account, :update?

    respond_to do |format|
      format.html
      format.js
    end
  end


  def update
    @rate_card = @account.rate_cards.find(params[:id])

    authorize @account, :update?

    respond_to do |format|
      if @rate_card.update_attributes(params[:rate_card])
        format.html {
          flash[:notice] = "Service has been saved successfully"
          redirect_to(rate_cards_path)
        }
        format.js
      else
        format.html { render :action => 'edit' }
        format.js { render :action => 'edit' }
      end
    end
  end


  def destroy
    @rate_card = @account.rate_cards.find(params[:id])

    authorize @account, :update?

    @rate_card.destroy

    flash[:notice] = "Service has been successfully removed"
    respond_to do |format|
      format.html { redirect_to(rate_cards_path) }
    end
  end

private

  def breadcrumbs
    @breadcrumbs.add_breadcrumb('Dashboard', root_path)
    @breadcrumbs.add_breadcrumb('Settings', settings_path)
  end

end

