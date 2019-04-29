class ClientRateCardsController < ToolApplicationController

  # Callbacks
  before_filter :find_client


  # Show all services along with over-rides
  def index
    @rate_cards = @account.rate_cards.service_type_ordered

    authorize @client, :read?

    respond_to do |format|
      format.html
    end
  end


  def new
    @rate_card = @account.rate_cards.find(params[:rate_card_id])
    @client_rate_card = @client.client_rate_cards.new(:daily_cost => @rate_card.daily_cost, :rate_card_id => @rate_card.id)

    authorize @client, :create?

    respond_to do |format|
      format.html
      format.js
    end
  end


  def create
    @client_rate_card = @client.client_rate_cards.new(params[:client_rate_card])
    @rate_card = @account.rate_cards.find(@client_rate_card.rate_card_id)

    authorize @client, :create?

    respond_to do |format|
      if @client_rate_card.save
        format.html {
          flash[:notice] = "Daily cost has been successfully updated"
          redirect_to(client_client_rate_cards_path(@client))
        }
        format.js
      else
        format.html {render :action => 'new'}
        format.js {render :action => 'new'}
      end
    end
  end


  def edit
    @client_rate_card = @client.client_rate_cards.find(params[:id])
    @rate_card = @account.rate_cards.find(@client_rate_card.rate_card_id)

    authorize @client, :update?

    respond_to do |format|
      format.html
      format.js
    end
  end


  def update
    @client_rate_card = @client.client_rate_cards.find(params[:id])
    @rate_card = @account.rate_cards.find(@client_rate_card.rate_card_id)

    authorize @client, :update?

    respond_to do |format|
      if @client_rate_card.update_attributes(params[:client_rate_card])
        format.html {
          flash[:notice] = "Daily cost has been successfully updated"
          redirect_to(client_client_rate_cards_path(@client))
        }
        format.js
      else
        format.html {render :action => 'edit'}
        format.js {render :action => 'edit'}
      end
    end
  end


  def destroy
    @client_rate_card = @client.client_rate_cards.find(params[:id])

    authorize @client, :destroy?

    @client_rate_card.destroy

    flash[:notice] = "Client service rate has been removed and the default has been restored"
    respond_to do |format|
      format.html {redirect_to(client_client_rate_cards_path(@client))}
    end
  end


  protected


  # find the associated client
  def find_client
    @client = @account.clients.find(params[:client_id])
  end
end

