class ClientRateCard < ActiveRecord::Base


  # External libs


  # Relationships
  belongs_to :client
  belongs_to :rate_card


  # Validation
  validates :daily_cost, :client, :rate_card, :presence => true
  validates :daily_cost, :numericality => {:only_integer => false, :greater_than => -1}, :allow_blank => true
  validates_uniqueness_of :client_id, :case_sensitive => false, :message => "already has a custom rate for this service type", :scope => [:rate_card_id]
  validate  :relations_must_belong_to_same_account


  # Virtual attributes


  # Callbacks


  # Mass assignment protection
  attr_accessible :daily_cost, :rate_card_id


  # Plugins


#
# Extract functions
#


  # Default scope


  # Named scopes


  #
  # Get the daily cost in whole dollers
  def daily_cost
    if daily_cost_cents.present?
      read_attribute(:daily_cost_cents) / 100.0
    else
      nil
    end
  end


  # Set the daily amount in cents from dollers
  def daily_cost=(amount_dollars)
    if amount_dollars.present?
      write_attribute(:daily_cost_cents, amount_dollars.to_f * 100)
    else
      write_attribute(:daily_cost_cents, nil)
    end
  end


#
# Save functions
#


#
# General functions
#


  protected


  #
  # Check that both the client and rate card belong to the same account
  def relations_must_belong_to_same_account
    if self.client.present? && self.rate_card.present?
      errors.add(:client_id, "and rate card must belong to the same account") if self.client.account_id != self.rate_card.account_id
    end
  end


end
