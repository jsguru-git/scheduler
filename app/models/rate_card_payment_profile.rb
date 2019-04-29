class RateCardPaymentProfile < ActiveRecord::Base
  
  
  # External libs
  

  # Relationships
  belongs_to :rate_card
  belongs_to :payment_profile


  # Validation
  validates :rate_card_id, :payment_profile_id, :percentage, :presence => true
  validates :percentage, :numericality => {:only_integer => true, :greater_than => 0}, :allow_blank => true
  validate  :check_associated
  

  # Callbacks


  # Mass assignment protection
  attr_accessible :rate_card_id, :payment_profile_id, :percentage
  


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
  
  
  # Check to see that the given rate card id belongs to the correct account
  def check_associated
    if self.payment_profile.present? && self.rate_card.present?
      project = self.payment_profile.project
      errors.add(:rate_card_id, "should belong to the same account as the payment profile") if rate_card.account_id != project.account_id
    end
  end
  
  
end
