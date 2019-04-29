class DocumentComment < ActiveRecord::Base
  
  
  # External libs
  include SharedMethods
  
  
  # Relationships
  belongs_to :user
  belongs_to :document
  
  
  # Validation
  validates :document_id, :comment, :presence => true
  validate  :check_associated
  
  
  # Callbacks
  before_validation :remove_whitespace
  
  
  # Mass assignment protection
  attr_accessible :comment
  
  
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


  # Check to see that the given document and user belong to the same account
  def check_associated
    if self.document_id.present? && self.user_id.present?
      project = self.document.project
      
      self.errors.add(:user_id, 'must belong to the same account as the document') if project.account_id != self.user.account_id
    end
  end


end
