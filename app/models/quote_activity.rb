class QuoteActivity < ActiveRecord::Base
  
  
  # External libs
  include SharedMethods
  include EstimateTime
  
  
  # Relationships
  belongs_to :quote, :touch => true
  belongs_to :rate_card
  has_one :task
  
  
  # Validation
  validates :name, :rate_card_id, :quote_id, :estimate_type, :presence => true
  validates :estimate_type, :inclusion => { :in => SELECTIONS['estimate_type'].keys }
  validates :discount_percentage, :numericality => {:only_integer => false, :greater_than => -0.01, :less_than => 100.01}, :allow_blank => true, :presence => true
  validate  :check_associated
  validate  :check_if_quote_is_editable
  
  
  # Callbacks
  before_validation :set_min_values_to_max_if_exact_estimate
  before_validation :remove_whitespace
  before_save :calculate_cost
  
  
  # Mass assignment protection
  attr_accessible :name, :rate_card_id, :estimate_type, :discount_percentage
  
  
  # Plugins
  acts_as_list :scope => :quote
  


#
# Extract functions
#
  
  
  # Named scopes
  scope :position_ordered, order('quote_activities.position')
  
  
  # Output the min amount in the quote report currency
  def min_amount_cents_in_report_currency
    Currency.convert_amount(self.quote.project.account.account_setting.default_currency, self.quote.currency, self.min_amount_cents, self.quote.report_currency_exchange_rate)
  end
  
  
  # Output the max amount in the quote report currency
  def max_amount_cents_in_report_currency
    Currency.convert_amount(self.quote.project.account.account_setting.default_currency, self.quote.currency, self.max_amount_cents, self.quote.report_currency_exchange_rate)
  end
  
  
  # Remove trailing 0's
  def discount_percentage_out
    self.discount_percentage.to_s.sub(/(?:(\..*[^0])0+|\.0+)$/, '\1')
  end
  
  

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

  # Public: Changes QuoteActivity to the params of a Task
  #
  # Returns a Hash of attributes
  def to_task_attributes
    task = {}
    task[:name] = name
    task[:estimated_minutes] = max_estimated_minutes
    task[:rate_card_id] = rate_card_id
    task[:quote_activity_id] = id
    task[:count_towards_time_worked] = true

    task
  end


protected
  
  
  # Check to see if belogns to same project
  def check_associated
    if self.rate_card_id.present? && self.quote_id.present?
      errors.add(:rate_card_id, "does not belong to the same account as the quote") if self.rate_card.account_id != self.quote.project.account_id
    end
  end
  
  
  # Calculate cost based on the selected service type and mins
  def calculate_cost
    if self.rate_card.present?
      cost_per_day = self.rate_card.most_relevant_rate_card_for(self.quote.project.client_id).daily_cost_cents
      acc_settings = self.quote.project.account.account_setting
      
      self.min_amount_cents = ((self.min_estimated_minutes.to_s.to_d / acc_settings.working_day_duration_minutes) * cost_per_day)
      self.max_amount_cents = ((self.max_estimated_minutes.to_s.to_d / acc_settings.working_day_duration_minutes) * cost_per_day)

      
      # Apply discount if set
      if self.discount_percentage.present? && self.discount_percentage != 0.0
        self.min_amount_cents -= self.calculate_discount_for(self.min_amount_cents) if self.min_amount_cents != 0
        self.max_amount_cents -= self.calculate_discount_for(self.max_amount_cents) if self.max_amount_cents != 0
      end
      
      # Round figures off
      self.min_amount_cents = self.min_amount_cents.round(2)
      self.max_amount_cents = self.max_amount_cents.round(2)
    else
      self.min_amount_cents = 0
      self.max_amount_cents = 0
    end
  end
  
  
  # Calculate the discount for a given amount
  def calculate_discount_for(total)
    if self.discount_percentage.present? && self.discount_percentage != 0.0
      (total / 100) * self.discount_percentage.round(2)
    else
      0
    end
  end
  
  
  # If exact match, update min values
  def set_min_values_to_max_if_exact_estimate
    if self.estimate_type == 0
      self.min_estimated_minutes = self.max_estimated_minutes
      self.min_estimated = self.max_estimated
    end
  end
  
  
  # Checks to see if the quote is editable
  def check_if_quote_is_editable
    self.errors.add(:base, "Quote is no longer editable as there is either a new version or the status is no longer in-progress") if !self.quote.editable?
  end
  
  
end
