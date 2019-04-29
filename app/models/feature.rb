class Feature < ActiveRecord::Base


  # External libs
  include SharedMethods


  # Relationships
  belongs_to :project
  has_many   :tasks, :dependent => :nullify


  # Validation
  validates :project_id, :presence => true
  validates :name, :presence => true, :length => { :maximum => 255 }
  validates :description, :length => { :maximum => 2000 }


  # Callbacks
  before_validation :remove_whitespace


  # Mass assignment protection
  attr_accessible :name, :description


#
# Extract functions
#


  # Named scopes
  scope :name_ordered, order('features.name')


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
