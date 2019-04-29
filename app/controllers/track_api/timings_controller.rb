class TrackApi::TimingsController < ToolApplicationController

  # Request url: <domain>/track_api/timings.json
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
  # - _Default_: 7 days after start date
  # (Only supply 1)
  # user_id::
  # - _Type_: Integer
  # - _Default_: nil
  # team_id::
  # - _Type_: Integer
  # - _Default_: nil
  def index
    cal = Calendar.new(params, 6)
    @timings = Timing.search(@account, cal, params)
    authorize Timing, :read?
    respond_to do |format|
      if can_read_timing?
        format.json {
          render :json => @timings.includes([:task, :project]).to_json(:include => [:project,
                                                        :task => { :only => [:name, :count_towards_time_worked] }])
        }
      else
        format.json { render :json => { :status => 'Unauthorized' },
                             :status => :unauthorized }
      end
    end
  end


  #
  # Description: Creates a new timing.
  #
  # Request url: <domain>/track_api/timings.json
  #
  # Request type: POST
  #
  # Request types: json
  #
  # === Params
  # user_id (req)::
  # - _Type_: Integer
  # timing::
  #  started_at (req)::
  #  - _Type_: DateTime (e.g. '2012-05-09 10:00:30)
  #  ended_at (req)::
  #  - _Type_: DateTime (e.g. '2012-05-09 10:59:30')
  #  project_id (req)::
  #  - _Type_: Integer
  #  task_id::
  #  - _Type_: Integer
  #  notes::
  #  - _Type_: Text
  def create
    @user = @account.users.find(params[:user_id])
    @timing = @user.timings.new(params[:timing])
    authorize @timing, :create?

    respond_to do |format|
	    if !can_create_timing?(@user, @timing)
	      format.json { render :json => { :status => 'Unauthorized' }, :status => :unauthorized }
      elsif @timing.save
        format.json { render :json => @timing.to_json(:include => [:project,
                                                                   :task => { :only => [:name, :count_towards_time_worked] }]
                                                     ), :status => :created }
      else
        format.json { render :json => @timing.errors.full_messages, :status => :unprocessable_entity }
      end
    end
  end


  #
  # Description: Update an existing timing.
  #
  # Request url: <domain>/track_api/timings/{id}.json
  #
  # Request type: PUT
  #
  # Request types: json
  #
  # === Params
  # id (req)::
  # - _Type_: Integer
  # user_id (req)::
  # - _Type_: Integer
  # timing::
  #  started_at::
  #  - _Type_: DateTime (e.g. '2012-05-09 10:00:00)
  #  ended_at::
  #  - _Type_: DateTime (e.g. '2012-05-09 10:59:00')
  #  project_id::
  #  - _Type_: Integer
  #  task_id::
  #  - _Type_: Integer
  #  notes::
  #  - _Type_: Text
  def update
    @user = @account.users.find(params[:user_id])
    @timing = @user.timings.find(params[:id])
    authorize @timing, :update?
    respond_to do |format|
      if !can_update_timing?(@user, @timing)
        format.json  { render :json => { :status => 'Unauthorized' }, :status => :unauthorized }
      elsif @timing.update_attributes(params[:timing])
        format.json  { render :json => @timing.to_json(:include => [:project,
                                                                    :task => { :only => [:name, :count_towards_time_worked] }]
                                                      )}
      else
        format.json  { render :json => @timing.errors, :status => :unprocessable_entity }
      end
    end
  end


  #
  # Description: Delete a given timing.
  #
  # Request url: <domain>/track_api/timings/{id}.json
  #
  # Request type: DELETE
  #
  # Request types: json
  #
  # === Params
  # id (req)::
  # - _Type_: Integer
  # user_id (req)::
  # - _Type_: Integer
  def destroy
    @user = @account.users.find(params[:user_id])
    @timing = @user.timings.find(params[:id])
    authorize @timing, :destroy?
    respond_to do |format|
      if !can_update_timing?(@user, @timing)
        format.json  { render :json => { :status => 'Unauthorized' }, :status => :unauthorized }
      elsif @timing.destroy
        format.json  { head :no_content }
      else
        format.json  { render :json => { :deleted => 'fail' }, :status => :unprocessable_entity }
      end
    end
  end


protected


  #
  # Checks to see if the user can update the entry
  def can_update_timing?(permission_user, permission_timing)
    # If account holder or admin, they can do everything
    if has_permission?('account_holder || administrator')
      true
    else
      # Check if user id is same as logged in or that the entry has not been submitted
      if permission_user.id != current_user.id || permission_timing.submitted?
        false
      else

        # Check day has not been submitted
        if permission_timing.started_at.present? && permission_timing.ended_at.present?
          if Timing.submitted_for_period?(permission_user.id, permission_timing.started_at.to_date, permission_timing.ended_at.to_date) 
            false
          else
            true
          end
        else
          # This will be an invalid record, so let user edit to get validation messages
          true
        end
      end
    end
  end


  #
  # Checks to see if the user can create the entry
  def can_create_timing?(permission_user, permission_timing)
    # If account holder or admin, they can do everything
    if has_permission?('account_holder || administrator')
      true
    else
      # Check if user id is same as logged in
      if permission_user.id != current_user.id
        false
      else
        # Check day has not been submitted
        if permission_timing.started_at.present? && permission_timing.ended_at.present?
          if Timing.submitted_for_period?(permission_user.id, permission_timing.started_at.to_date, permission_timing.ended_at.to_date) 
            false
          else
            true
          end
        else
          # This will be an invalid record, so let user edit to get validation messages
          true
        end
        
      end
    end
  end
  

  def can_read_timing?
    # If account holder or admin, they can do everything
    if has_permission?('account_holder || administrator')
      return true
    else
      if params[:team_id].present?
        false
      elsif params[:user_id].present?
        permission_user = @account.users.find(params[:user_id])
        if permission_user.id != current_user.id
          false
        else
          true
        end
      else
        false
      end
    end
  end
  
    
end

