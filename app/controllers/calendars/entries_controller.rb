class Calendars::EntriesController < ToolApplicationController

  respond_to :json

  #
  # Description: Returns all entries that fall between a given time range.
  #
  # Request url: <domain>/calendars/entries.json
  #
  # Request type: GET
  #
  # Request types: json
  #
  # === Params
  # start_date::
  # - _Type_: Date (e.g. '2012-05-29')
  # - _Default_: previous sunday
  # end_date::
  # - _Type_: Date (e.g. '2012-05-29')
  # - _Default_: 3 weeks after start date
  # project_id::
  # - _Type_: Integer
  # - _Default_: nil
  def index
    @cal = Calendar.new(params)

    if params[:project_id].blank?
      @entries = Entry.for_period(@account.id, @cal.start_date, @cal.end_date)
    else
      @project = @account.projects.find(params[:project_id])
      @entries = Entry.for_project_period(@project.id, @cal.start_date, @cal.end_date)
    end

    authorize @entries, :read?

    respond_to do |format|
      format.json {render :json => @entries.to_json(:except => [:account_id], :include => [:project])}
    end
  end


  #
  # Description: Returns all entries that fall between a given time range
  # for a given user_id
  #
  # Request url: <domain>/calendars/entries_for_user.json
  #
  # Request type: GET
  #
  # Request types: json
  #
  # === Params
  # start_date::
  # - _Type_: Date (e.g. '2012-05-29')
  # - _Default_: previous sunday
  # end_date::
  # - _Type_: Date (e.g. '2012-05-29')
  # - _Default_: 3 weeks after start date
  # user_id::
  # - _Type_: Integer
  # - _Default_: nil
  def entries_for_user

    @items = @account.entries.for_user_period(
    params[:user_id], params[:start_date], params[:end_date])

    authorize @items, :report?

    # include the project name to save doing difficult lookups in js
    @entries = @items.to_json(:include => { :project => {
    :only => [:id, :name] }})

    respond_with(@entries)
  end


  #
  # Description: Creates a new entry.
  #
  # Request url: <domain>/calendars/entries.json
  #
  # Request type: POST
  #
  # Request types: json
  #
  # === Params
  # entry::
  #  start_date (req)::
  #  - _Type_: Date (e.g. '2012-05-29')
  #  end_date::
  #  - _Type_: Date (e.g. '2012-05-29')
  #  - _Default_: Same as start date
  #  user_id (req)::
  #  - _Type_: Integer
  #  project_id::
  #  - _Type_: Integer
  #  project_name::
  #  - _Type_: String
  def create

    params[:entry][:project_id] = @account.projects.find_or_create_by_name(name: params[:entry][:project_name]).try(:id)

    authorize Entry, :create?

    @entries = @account.entries.create_bulk(params[:entry], @account.account_setting.working_days, params[:exclude_non_working_days] == '1')

    @errors = @entries.map { |e| e.errors.any? ? e.errors : nil }.flatten.compact

    respond_to do |format|
      if @errors.empty?
        format.json { render :json => @entries.to_json(:except => [:account_id], :include => [:project]), :status => :created }
      else
        format.json { render :json => @errors, :status => :unprocessable_entity }
      end
    end
  end

  #
  # Description: Update an existing entry.
  #
  # Request url: <domain>/calendars/entries/{id}.json
  #
  # Request type: PUT
  #
  # Request types: json
  #
  # === Params
  # id (req)::
  # - _Type_: Integer
  # entry::
  #  start_date::
  #  - _Type_: Date (e.g. '2012-05-29')
  #  end_date::
  #  - _Type_: Date (e.g. '2012-05-29')
  #  - _Default_: Same as start date
  #  user_id::
  #  - _Type_: Integer
  #  project_id::
  #  - _Type_: Integer
  #  project_name::
  #  - _Type_: String
  def update
    @entry = @account.entries.find(params[:id])

    authorize @entry, :update?

    respond_to do |format|
      if @entry.update_attributes(params[:entry])
        format.json  { head :no_content }
      else
        format.json  { render :json => @entry.errors, :status => :unprocessable_entity }
      end
    end
  end


  #
  # Description: Delete a given entry.
  #
  # Request url: <domain>/calendars/entries/{id}.json
  #
  # Request type: DELETE
  #
  # Request types: json
  #
  # === Params
  # id (req)::
  # - _Type_: Integer
  def destroy
    @entry = @account.entries.find(params[:id])

    authorize @entry, :destroy?

    respond_to do |format|
      if @entry.destroy
        format.json  { head :no_content }
      else
        format.json  { render :json => { :deleted => 'fail' }, :status => :unprocessable_entity }
      end
    end
  end


end
