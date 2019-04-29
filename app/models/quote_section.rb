class QuoteSection < ActiveRecord::Base
  
  
  # External libs
  include SharedMethods
  

  # Relationships
  belongs_to :quote, :touch => true
  
  
  # Validation
  validates :quote_id, :presence => true
  validate :check_if_quote_is_editable
  
  
  # Callbacks
  before_validation :remove_whitespace
  
  
  # Mass assignment protection
  attr_accessible :title, :content

  
  # Plugins
  acts_as_list :scope => :quote



#
# Extract functions
#
  
  
  # Named scopes
  scope :position_ordered, order('quote_sections.position')
  
  

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
  
  
  #
  # Checks to see if the quote is editable
  def check_if_quote_is_editable
    self.errors.add(:quote, "is no longer editable as there is either a new version or the status is no longer in-progress") if !self.quote.editable?
  end
  
  
end
