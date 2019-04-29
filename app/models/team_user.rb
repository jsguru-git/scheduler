class TeamUser < ActiveRecord::Base


  # External libs
  

  # Relationships
  belongs_to :team
  belongs_to :user


  # Validation
  validates :user_id, uniqueness: { scope: :team_id }

  # Callbacks


  # Mass assignment protection
  attr_accessible :team_id


  # Plugins


  #
  # Extract functions
  #


  # Named scopes


  #
  # Save functions
  #


  #
  # Create functions
  #


  #
  # Update functions
  #


  #
  # General functions
  #


  protected
end
