class ProjectComment < ActiveRecord::Base
  
  
  # External libs
  include SharedMethods
  
  
  # Relationships
  belongs_to :user
  belongs_to :project
  belongs_to :project_comment_replied_to, :class_name => "ProjectComment", :foreign_key => 'project_comment_id'
  has_many   :project_comment_replies,    :class_name => "ProjectComment", :foreign_key => 'project_comment_id', :dependent => :destroy
  
  
  # Validation
  validates :project_id, :comment, :presence => true
  validate  :check_associated
  
  
  # Callbacks
  before_validation :remove_whitespace
  
  
  # Mass assignment protection
  attr_accessible :comment, :project_comment_id
  
  
  # Plugins


#
# Extract functions
#


  # Named scopes
  scope :comemnt_date_order, order('project_comments.created_at')
  scope :original_comments, where(["project_comment_id IS ?", nil])


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
    if self.project_id.present? && self.user_id.present?
      self.errors.add(:user_id, 'must belong to the same account as the project') if self.project.account_id != self.user.account_id
    end
    
    if self.project_comment_id.present?
      self.errors.add(:project_comment_id, 'must belong to the same project as the replied to comment') if self.project_id != self.project_comment_replied_to.project_id
    end
  end
  
  
end
