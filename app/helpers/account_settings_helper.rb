module AccountSettingsHelper


  def plan_amount_text amount
    if amount == nil
      'Unlimited'
    else
      amount
    end
  end


  # css class for table rows
  def account_row_class_name(plan)
    if @account.account_plan_id == plan.id
      'current_plan'
    else
      'account_plan'
    end
  end


  def should_show_plan(plan)

    # Normal checks
    return true if @account.account_plan_id == plan.id

    # Get limit table names
    table_names = AccountPlan.get_limit_model_types
    should_allow = true

    # Check we have not exceeded this list
    table_names.each do |table_name|
      column_name = "no_#{table_name}s"
      if (plan.send(column_name) == nil || plan.send(column_name) >= @account.count_for_model(table_name.camelize) )
      else
        should_allow = false
      end
    end

    return should_allow

  end
end
