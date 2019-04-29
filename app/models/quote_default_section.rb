class QuoteDefaultSection < ActiveRecord::Base
  
  # External libs
  include SharedMethods

  # Relationships
  belongs_to :account
  
  # Validation
  validates :account_id, :presence => true
  
  # Callbacks
  before_validation :remove_whitespace
  
  # Mass assignment protection
  attr_accessible :title, :content

  # Plugins
  acts_as_list :scope => :account

#
# Extract functions
#
  
  # Named scopes
  scope :position_ordered, order('quote_default_sections.position')

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
