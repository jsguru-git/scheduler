class ClientsController < ToolApplicationController
  
  before_filter :breadcrumbs

  def index
    params[:archived] ||= '0'
    @clients = Client.search(@account, params)
    authorize @clients, :read?
    respond_to do |format|
      format.html
    end
  end


  def new
    @client = @account.clients.new
    authorize @client, :create?
    respond_to do |format|
     format.html
     format.js
    end
  end


  def edit
    @client = @account.clients.find(params[:id])
    authorize @client, :update?
    respond_to do |format|
      format.html
    end
  end


  def show
    @client = @account.clients.find(params[:id])
    authorize @client, :read?
    # Schedule
    if @account.component_enabled?(1)
      @people_scheduled = @client.all_people_scheduled
      @people_in_next_week = @client.people_scheduled_for_next_week_from(Time.now.beginning_of_week.in_time_zone.to_date)
    end

    # Track
    if @account.component_enabled?(2)
      @tracked_this_week = @client.people_tracked_for_a_week_from(Time.now.beginning_of_week.in_time_zone.to_date)
      @people_tracked = @client.all_people_tracked
    end

    respond_to do |format|
      format.html
    end
  end


  def update
    @client = @account.clients.find(params[:id])
    authorize @client, :update?
    respond_to do |format|
      if @client.update_attributes(params[:client])
        format.html {redirect_to(client_path(@client))}
      else
        format.html {render :action => 'edit'}
      end
    end
  end


  def create
    @client = @account.clients.new(params[:client])
    authorize @client, :create?
    respond_to do |format|
      if @client.save
        format.html {
          flash[:notice] = "Client has been successfully created"
          redirect_to(client_path(@client))
        }
        format.js
      else
        format.html {render :action => 'new'}
        format.js   {render :action => 'new'}
      end
    end
  end


  def cancel
    respond_to do |format|
      format.html{redirect_to(new_project_path)}
      format.js
    end
  end


  def archive
    @client = @account.clients.find(params[:id])
    authorize @client, :update?
    @client.archive_now

    respond_to do |format|
      flash[:notice] = "Client has been successfully archived"

      format.html { redirect_to(client_path(@client)) }
    end
  end


  def activate
    @client = @account.clients.find(params[:id])
    authorize @client, :update?
    @client.un_archive_now

    respond_to do |format|
      flash[:notice] = "Client has been successfully re-activated"

      format.html { redirect_to(client_path(@client)) }
    end
  end
  
  
  
  
private

  def breadcrumbs
    @breadcrumbs.add_breadcrumb('Dashboard', root_path)
    @breadcrumbs.add_breadcrumb('People', users_path)
    @breadcrumbs.add_breadcrumb('Clients', clients_path) unless params[:action] == 'index'
  end
  
end
