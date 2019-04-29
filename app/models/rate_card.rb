class RateCard < ActiveRecord::Base
  
  
  # External libs
  include SharedMethods


  # Relationships
  belongs_to :account
  has_many :client_rate_cards, :dependent => :destroy
  has_many :quote_activities, :dependent => :nullify
  has_many :tasks, :dependent => :nullify
  has_many :rate_card_payment_profiles, :dependent => :destroy
  has_many :payment_profiles, :through => :rate_card_payment_profiles


  # Validation
  validates :service_type, :daily_cost, :presence => true
  validates :service_type, :length => { :maximum => 150 }
  validates_uniqueness_of :service_type, :case_sensitive => false, :message => "already exists", :scope => [:account_id]
  validates :daily_cost, :numericality => {:only_integer => false, :greater_than => -1}, :allow_blank => true
  

  # Virtual attributes


  # Callbacks
  before_validation :remove_whitespace


  # Mass assignment protection
  attr_accessible :service_type, :daily_cost
  

  # Plugins


#
# Extract functions
#


  # Default scope


  # Named scopes
  scope :service_type_ordered, order('rate_cards.service_type')


  #
  #  Get the daily cost in the highest delimitation
  def daily_cost
    if daily_cost_cents.present?
      read_attribute(:daily_cost_cents) / 100.0
    else
      nil
    end
  end
  
  
  #
  # Set the daily cost from the highest delimitation
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


  #
  # attempts to find a client rate card entry for a given client and if not, returns nil
  def custom_for_client(client_id)
    self.client_rate_cards.where(["client_rate_cards.client_id = ?", client_id]).first
  end
  
  
  #
  # return the most relevant rete_card
  def most_relevant_rate_card_for(client_id)
    if client_id.present?
      self.custom_for_client(client_id)
      client_rate_card = self.custom_for_client(client_id)
      return client_rate_card if client_rate_card.present?
    end
    
    self
  end
  
  
  #
  # Get cost for a minutes work for a given client
  def cost_per_min_for_client(client_id, account_instance)
    mins_in_day = account_instance.account_setting.working_day_duration_minutes
    # Get most suitable rate card
    r_card = self.most_relevant_rate_card_for(client_id)
    cost_cents_per_min = r_card.daily_cost_cents.to_s.to_d / mins_in_day
  end
  

protected
  

  
    
end
