class PaymentProfile < ActiveRecord::Base
  
  
  # External libs
  include SharedMethods


  # Relationships
  belongs_to :project
  has_one :invoice_item, :dependent => :nullify
  
  has_many :rate_card_payment_profiles, :dependent => :destroy
  has_many :rate_cards, :through => :rate_card_payment_profiles
  has_many :payment_profile_rollovers, :dependent => :nullify


  # Validation
  validates :name, :expected_payment_date, :project_id, :presence => true
  validates :reason_for_date_change, presence: true, if: :expected_payment_date_changed_more_than_a_month?, on: :update
  
  validates :expected_cost_cents, :numericality => {:only_integer => true, :greater_than => -1}, :allow_blank => true
  validates :expected_cost, :numericality => {:only_integer => false, :greater_than => -1}, :allow_blank => true
  
  validates :expected_minutes, :numericality => {:only_integer => false}, :allow_blank => true
  validates :expected_days, :numericality => {:only_integer => false, :greater_than => -1}, :format => {:with => /\A\d+\.?\d{0,2}\z/, :message => 'can only be to two decimal place' }, :allow_blank => true
  
  validate  :check_associated_rate_cards
  
  
  # Callbacks
  before_validation :remove_whitespace
  before_save :calculate_cost_based_on_mins
  before_destroy :check_if_can_be_removed
  after_save :check_for_date_change, on: :update
  
  
  # Mass assignment protection
  attr_accessible :name, :expected_payment_date, :expected_days, :expected_cost, :generate_cost_from_time, :rate_card_payment_profiles_attributes, :reason_for_date_change
  
  
  # Virtual attr's
  attr_accessor :expected_cost, :expected_days, :reason_for_date_change, :last_saved_by_id
  
  
  # Nested attributes
  accepts_nested_attributes_for :rate_card_payment_profiles, :allow_destroy => true, :reject_if => proc { |attrs| attrs['rate_card_id'].blank?}
  
  
  # Plugins
  

#
# Extract functions
#


  # Named scopes
  scope :expected_payment_date_ordered, order('payment_profiles.expected_payment_date')
  scope :un_invoiced, where("invoice_items.id IS ?", nil).includes(:invoice_item)


  #
  # Output expected cost in dollers or equivalent in a human readable format
  def expected_cost_formatted
    self.expected_cost_cents = 0 if expected_cost_cents.blank?
    Money.new(self.expected_cost_cents, Money.default_currency).format(
      :no_cents_if_whole => true,
      :symbol => Money.default_currency.symbol)
  end
  
  
  #
  # Output the % of service types assigned
  def service_type_percentage
    self.rate_card_payment_profiles.sum(:percentage)
  end
  
  
  #
  # Search payment profiles
  def self.search_stages(project, params)
    profiles = project.payment_profiles.expected_payment_date_ordered
    
    if params[:stages].present? && params[:stages].to_i == 1
      profiles = profiles.includes([:invoice_item]).where(["invoice_items.id IS ?", nil])
    elsif params[:stages].present? && params[:stages].to_i == 2
      profiles = profiles.includes([:invoice_item]).where(["invoice_items.id IS NOT ?", nil])
    end
    
    profiles
  end
  
  
  # Find all un-inoviced payment profiles between the given dates
  def self.un_invoiced_expected_for_between_dates(start_date, end_date)
    PaymentProfile.where(['payment_profiles.expected_payment_date <= ? AND payment_profiles.expected_payment_date >= ? and invoice_items.id IS ?', end_date, start_date, nil]).includes([:invoice_item, :project])
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
  
  
  #
  # Expected cost in dollers or equivalent
  def expected_cost
    if expected_cost_cents.present?
      read_attribute(:expected_cost_cents) / 100.0
    else
      0
    end
  end
  
  
  #
  # Set the cents when the doller equivalent is set
  def expected_cost=(amount_dollars)
    if amount_dollars.present?
      write_attribute(:expected_cost_cents, (amount_dollars.to_s.to_d * 100).to_i)
    else
      write_attribute(:expected_cost_cents, 0)
    end
  end
  
  
  #
  # Convert mins to days
  def expected_days
    return nil if self.expected_minutes.blank?
    return 0 if self.expected_minutes == 0

    mins_per_day = self.project.account.account_setting.working_day_duration_minutes
    (read_attribute(:expected_minutes) / mins_per_day.to_s.to_d)
  end
  
  
  #
  # Convert the passed in days into mins
  def expected_days=(days)
    if days.blank?
      write_attribute(:expected_minutes, nil)
    elsif days == 0
      write_attribute(:expected_minutes, 0)
    else
      mins_per_day = self.project.account.account_setting.working_day_duration_minutes
      mins = (days.to_s.to_d * mins_per_day)
      write_attribute(:expected_minutes, mins)
    end
  end
  
  
  # Calcualte the cost based on the associated service types and the mins
  def calculate_cost_based_on_mins
    if self.generate_cost_from_time?
      # Reset to 0
      self.expected_cost_cents = 0
      
      if self.project.present? && self.rate_card_payment_profiles.present? && self.expected_minutes.present? && self.expected_minutes != 0
        self.rate_card_payment_profiles.each do |rate_card_payment_profile|
          cost_per_min = rate_card_payment_profile.rate_card.cost_per_min_for_client(self.project.client_id, self.project.account)
          mins_for_rate_card = (self.expected_minutes / 100.0) * rate_card_payment_profile.percentage
          self.expected_cost_cents += mins_for_rate_card * cost_per_min
        end
      end
      
    end
  end
  
  protected
  
  # If there is an associated invoice, dont allow this record to be remvoed
  def check_if_can_be_removed
    return false if self.invoice_item.present?
  end
  
  
  # Validates that associated rate cards are valid and only appear onece
  def check_associated_rate_cards
    # requirements
    unless self.rate_card_payment_profiles.blank?
      current_ids = []
      added_to_parent = false
      total_percentage = 0

      self.rate_card_payment_profiles.each do |r|
        # Validate uniqueness of association
        if current_ids.include?(r.rate_card_id)
          errors.add('Rate card', "can only be included once") unless added_to_parent
          added_to_parent = true
          r.errors.add(:rate_card_id, "can only be included once")
        else
          current_ids << r.rate_card_id unless r.rate_card_id.blank?
        end
          total_percentage += r.percentage if r.percentage.present?
      end

      if total_percentage > 100
        errors.add('Rate card', "percentage total must not be greater than 100%")
      end
    end
  end
  
  
  # Check for date change and create audit if it has.
  def check_for_date_change
    if self.expected_payment_date_changed_more_than_a_month?
      # Date has changed month, so crate an rollover entry
      PaymentProfileRollover.create_entry(self)
    end
  end
  
  
  # Checks to see if the date has changed > 1 month
  def expected_payment_date_changed_more_than_a_month?
    if self.expected_payment_date_changed?
      old_date = self.changes[:expected_payment_date][0]
      if self.expected_payment_date.present? && old_date.present?
        return true if self.expected_payment_date.year != old_date.year || self.expected_payment_date.month != old_date.month
      end
    end
    false
  end
  
  
end
