module AccountsHelper


  #
  # Works out if a radio button for the plan selection should be selected
  def plan_radio_button_checked(plan_id)
    if params[:plan_id].present?
      if plan_id.to_s == params[:plan_id]
        true
      else
        false
      end
    elsif plan_id == 2
      true
    else
      false
    end
  end


  #
  # Decides if a given checkbox should be checked or not
  def should_component_be_checked(component_name)
    if params[:from].blank?
      true
    else
      if component_name.downcase == params[:from]
        true
      else
        false
      end
    end
  end


end
