class Role < ActiveRecord::Base


  # External libs
  

  # Relationships
  has_and_belongs_to_many :users


  # Validation
  validates_presence_of :title


  # Callbacks


  # Mass assignment protection
  attr_accessible :title


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
