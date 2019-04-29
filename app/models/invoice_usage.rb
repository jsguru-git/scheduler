class InvoiceUsage < ActiveRecord::Base


  # External libs
  include SharedMethods
  

  # Relationships
  belongs_to :invoice
  belongs_to :user
  

  # Validation
  validates :invoice_id, :name, :allocated_at, :presence => true
  validates :amount, :numericality => {:only_integer => false, :greater_than => 0}, :allow_blank => true, :presence => true
  validate :check_associated
  validate :check_total_amount_is_not_greater_than_invoice
  

  # Callbacks
  before_validation :set_allocated_at, :on => :create
  before_validation :remove_whitespace


  # Mass assignment protection
  attr_accessible  :name, :amount, :allocated_at
  
  
  # Virtual attr's
  attr_accessor :amount


  # Plugins


#
# Extract functions
#


  # Named scopes


  # Work out how much money is un-assigned for the given pre-payment invoice
  def self.amount_remaining_for(invoice_instance)
    invoice_instance.total_amount_cents_exc_vat - invoice_instance.invoice_usages.sum(:amount_cents)
  end
  
  
  # Total amount allocated for a period of time in the accounts default currency
  def self.amount_cents_allocated_for_period(account, start_date, end_date)
    total_default_current_cents = 0
    usages = InvoiceUsage.allocated_for_period_and_account(account, start_date, end_date)
    
    usages.each do |usage|
      # Convert to default currency if needed by using hte cached exchange rate in the invoice
      if usage.invoice.exchange_rate == 1
        total_default_current_cents += usage.amount_cents
      else
        account_default_currency = usage.invoice.project.account.account_setting.default_currency
        total_default_current_cents += Currency.convert_amount(usage.invoice.currency, account_default_currency, usage.amount_cents, usage.invoice.exchange_rate)
      end
    end
    
    total_default_current_cents
  end
  
  
  # All allocations for period and account
  def self.allocated_for_period_and_account(account, start_date, end_date)
    InvoiceUsage.where(['projects.account_id = ? AND invoice_usages.allocated_at <= ? AND invoice_usages.allocated_at >= ?', account.id, end_date, start_date]).includes({:invoice => :project}).order('invoice_usages.allocated_at')
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
  
  
  # Amount in dollers or equivalent
  def amount
    if amount_cents.present?
      read_attribute(:amount_cents) / 100.0
    else
      0
    end
  end
  
  
  # Set the cents when the doller equivalent is set
  def amount=(amount_dollars)
    if amount_dollars.present?
      write_attribute(:amount_cents, (amount_dollars.to_s.to_d * 100).to_i)
    else
      write_attribute(:amount_cents, 0)
    end
  end
  

protected
  
  
  # Check to see that the forign fields all belong to the same account
  def check_associated
    if self.user_id.present? && self.invoice_id.present?
      self.errors.add(:user_id, 'must belong to the same account as the invoice') if self.invoice.project.account_id != self.user.account_id
    end
  end
  
  
  def check_total_amount_is_not_greater_than_invoice
    if self.invoice_id.present?
      if self.new_record?
        current_total = invoice.invoice_usages.sum(:amount_cents)
      else
        current_total = invoice.invoice_usages.where(["invoice_usages.id != ?", self.id]).sum(:amount_cents)
      end
      current_total += self.amount_cents
      self.errors.add(:amount, 'total usage can not exceed the invoice total') if current_total > self.invoice.total_amount_cents_exc_vat
    end
  end


  # Set the allocated at date to today
  def set_allocated_at
    self.allocated_at = Date.today
  end
  

end
