class Calendars::ClientsController < ToolApplicationController

  #
  # Description: Returns all clients
  #
  # Request url: <domain>/calendars/clients.json
  #
  # Request type: GET
  #
  # Request types: json
  #
  # === Params
  # client_id::
  # - _Type_: Integer
  # - _Default_: nil
  def index
    @clients = @account.clients.order(:name)
    authorize @clients, :read?

    respond_to do |format|
      format.json {render :json => @clients.to_json}
    end
  end

  def show
    @client = Client.find(params[:id])
    authorize @client, :read?
    respond_to do |format|
      format.json {render :json => @client.to_json}
    end
  end


end
