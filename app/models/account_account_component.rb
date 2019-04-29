class AccountAccountComponent < ActiveRecord::Base


  # Relationships
  belongs_to :account
  belongs_to :account_component


  # Validation
  validates :account_id, :account_component_id, :presence => true


  # Mass assignment
  attr_accessible :account_component_id

end
