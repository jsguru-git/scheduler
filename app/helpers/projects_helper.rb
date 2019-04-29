module ProjectsHelper
  
  
  # Check to see if a given checkbox should be checked
  def should_team_be_checked(params_hash, team_id)
    return true if params_hash[:teams].blank? && params_hash[:commit].blank?
    
    if params_hash[:teams].present? && params_hash[:teams].include?(team_id.to_s)
      true
    else
      false
    end
  end
  
  
end
