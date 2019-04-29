class Invoice < ActiveRecord::Base


  # External libs
  include SharedMethods


  # Relationships
  belongs_to :project
  belongs_to :user
  has_many :invoice_items, :dependent => :destroy
  has_many :payment_profiles, :through => :invoice_items
  has_many :invoice_usages, :dependent => :restrict
  
  
  # Validation
  validates :invoice_date, :due_on_date, :invoice_number, :currency, :project_id, :exchange_rate, :presence => true
  validates :vat_rate, :total_amount_cents_exc_vat, :total_amount_cents_inc_vat, :default_currency_total_amount_cents_exc_vat, :default_currency_total_amount_cents_inc_vat, :numericality => {:only_integer => false, :greater_than => -1}, :allow_blank => true, :presence => true
  validates :invoice_status, :presence => true, :inclusion => 0..2
  validates :pre_payment, inclusion: { in: [true, false], message: 'status is not set' }
  validates_format_of :email, :allow_blank => true, :message => 'is not a valid format', :with => /\A([A-z0-9\.\-_]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i

  validate :check_unique_invoice_number
  validate :currency_should_be_in_supported
  validate :at_least_one_item
  validate :check_associated
  validate :payment_stage_can_only_be_invoiced_once


  # Callbacks
  before_validation :set_exchange_rate
  before_validation :set_amounts
  before_validation :set_default_currency_amounts
  before_validation :remove_whitespace
  after_create :send_alert_email


  # Mass assignment protection
  attr_accessible :invoice_date, :due_on_date, :invoice_number, :terms, :po_number, :currency, :vat_rate, :address, :payment_methods, :notes, :invoice_items_attributes, :pre_payment, :email


  # Virtual attr's


  # Plugins


  # Nested attributes
  accepts_nested_attributes_for :invoice_items, :allow_destroy => true


#
# Extract functions
#


  # Named scopes
  scope :invoice_date_order, order('invoices.invoice_date')
  scope :pre_payment_invoices, where(["invoices.pre_payment = ?", true])


  # Output the iso currency code
  def currency_code
    Money::Currency.new(self.currency).iso_code
  end


  # Output the currency symbol
  def currency_symbol
    Money::Currency.new(self.currency).symbol
  end


  # total_amount_cents_inc_vat in dollers or equivalent
  def total_amount_inc_vat
    if self.total_amount_cents_inc_vat.present?
      read_attribute(:total_amount_cents_inc_vat) / 100.0
    else
      0
    end
  end


  # total_amount_cents_exc_vat in dollers or equivalent
  def total_amount_exc_vat
    if self.total_amount_cents_exc_vat.present?
      read_attribute(:total_amount_cents_exc_vat) / 100.0
    else
      0
    end
  end


  # Return the vat anount in dollars or equivalent
  def vat_amount
    if self.vat_amount_cents != 0
      self.vat_amount_cents / 100.0
    else
      0
    end
  end


  # Return the vat amount in cents or equivalent
  def vat_amount_cents
    if self.total_amount_cents_inc_vat.present? && self.total_amount_cents_exc_vat.present?
      (self.total_amount_cents_inc_vat - self.total_amount_cents_exc_vat)
    else
      0
    end
  end


  # Format amount in the invoice currency
  def amount_in_currency(amount)
    Money.new(amount, currency).format(
      :no_cents_if_whole => false,
      :symbol => true)
  end

  
  # Provides total_amount_cents_exc_vat in the correct currency formatted string
  def total_amount_exc_vat_in_currency
    amount_in_currency(total_amount_cents_exc_vat)
  end


  # Provides total_amount_cents_inc_vat in the correct currency formatted string
  def total_amount_inc_vat_in_currency
    amount_in_currency(total_amount_cents_inc_vat)
  end
  
  
  # Set the defaults for when first showing a new form
  def set_defaults
    if self.project.present?
      if self.project.client.present?
        # Set address
        self.address = ''
        self.address += self.project.client.address if self.project.client.address.present?
        self.address += "\n" + self.project.client.zipcode if self.project.client.zipcode.present?
        
        self.email = self.project.client.email if self.project.client.email.present?
      end

      # Set default currency
      self.currency = self.project.account.account_setting.default_currency

      self.terms = 'Pay within 30 days'
      self.due_on_date = Date.today
      self.invoice_date = Date.today
      self.vat_rate = 20
      self.total_amount_cents_exc_vat = 0
      self.total_amount_cents_inc_vat = 0

      self.invoice_number = Invoice.find_next_available_number_for(self.project.account)
      self.pre_payment = false
    end
  end
  
  
  # Work out the next invoice number
  def self.find_next_available_number_for(account, default=0)
    # Cast as int in mysql just incase there are some non-integer invoice numbers in there.
    (Invoice.where(["projects.account_id = ?", account.id]).includes([:project]).maximum('CAST(invoices.invoice_number AS SIGNED)').to_i || default).succ
  end
  
  
  # Total amount invoiced for a given cleint for a period of time
  def self.amount_cents_invoiced_for_period_and_client(client_id, start_date, end_date)
    Invoice.where(['projects.client_id = ? AND invoices.invoice_date <= ? AND invoices.invoice_date >= ?', client_id, end_date, start_date]).includes(:project).sum(:default_currency_total_amount_cents_exc_vat)
  end
  
  
  # Total amount invoiced for a given project for a period of time
  def self.amount_cents_invoiced_for_period_and_project(project_id, start_date, end_date)
    Invoice.where(['invoices.project_id = ? AND invoices.invoice_date <= ? AND invoices.invoice_date >= ?', project_id, end_date, start_date]).sum(:total_amount_cents_exc_vat)
  end  
  
  # Total amount invoiced for a period of time
  def self.amount_cents_invoiced_for_period(account, start_date, end_date)
    Invoice.where(['projects.account_id = ? AND invoices.invoice_date <= ? AND invoices.invoice_date >= ?', account.id, end_date, start_date]).includes([:project]).sum(:total_amount_cents_exc_vat)
  end
  
  
  # Total amount pre-paid invoices for a period of time
  def self.amount_cents_pre_payment_invoiced_for_period(account, start_date, end_date)
    Invoice.where(['projects.account_id = ? AND invoices.invoice_date <= ? AND invoices.invoice_date >= ? AND invoices.pre_payment = ?', account.id, end_date, start_date, true]).includes([:project]).sum(:total_amount_cents_exc_vat)
  end
  
  
  # Search the pre payments
  def self.search_pre_payments(account, start_date, end_date, params)
    projects = account.projects
      .where(['invoices.invoice_date <= ? AND invoices.invoice_date >= ? AND invoices.pre_payment = ?', end_date, start_date, true])
      .includes([:invoices, :client])
      .order('clients.name, projects.name')
      
    projects = projects.where(["projects.id = ?", params[:project_id]]) if params[:project_id].present?
    projects = projects.where(["projects.client_id = ?", params[:client_id]]) if params[:client_id].present?
    
    projects
  end
  
  
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


  # Must have a unquie number for account
  def check_unique_invoice_number
    if self.invoice_number.present? && self.project.present?
      if self.new_record?
        self.errors.add(:invoice_number, 'has already been used') if Invoice.where(["invoices.invoice_number = ? AND projects.account_id = ?", self.invoice_number, self.project.account_id]).includes(:project).exists?
      else
        self.errors.add(:invoice_number, 'has already been used') if Invoice.where(["invoices.id != ? AND invoices.invoice_number = ? AND projects.account_id = ?", self.id, self.invoice_number, self.project.account_id]).includes(:project).exists?
      end
    end
  end


  # Check there is at least one item in this invoice
  def at_least_one_item
    self.errors.add(:base, 'At least one invoice item should be provided') unless self.invoice_items.present?
  end


  # Check chosen currency is supported
  def currency_should_be_in_supported
    self.errors.add(:currency, 'exchange rate can not be found and is not supported') if self.currency.present? && !Currency.exists?(:iso_code => self.currency)
  end


  # Check to see that the given payment profile id belongs to the correct project as the invoice
  def check_associated
    if self.invoice_items.present?
      self.invoice_items.each do |invoice_item|
        if self.project_id.present? && invoice_item.payment_profile.present?
          self.errors.add(:base, 'Payment stages must belong to the same project as the invoice') if self.project_id != invoice_item.payment_profile.project_id
        end
      end
    end
    
    if self.user_id.present?
      self.errors.add(:user_id, 'must belong to the same account as the invoice') if self.project.account_id != self.user.account_id
    end
  end


  # Should check payment profile id is unique
  def payment_stage_can_only_be_invoiced_once
    current_payment_profile_ids = []
    if self.invoice_items.present?
      self.invoice_items.each do |invoice_item|
        if invoice_item.payment_profile_id.present?
          # Check isnt in current invoice more than once
          if current_payment_profile_ids.include?(invoice_item.payment_profile_id)
             self.errors.add(:base, 'Payment stages can only be included in the invocie once')
             break # No point checling anymore
          else
            current_payment_profile_ids << invoice_item.payment_profile_id
          end
        end
      end

      # Check database
      if current_payment_profile_ids.present?
        existing_invoice_items = InvoiceItem.where(:payment_profile_id => current_payment_profile_ids)
        existing_invoice_items = existing_invoice_items.where(["invoice_id != ?", self.id]) unless self.new_record?

        self.errors.add(:base, 'Payment stages can only be invoiced once and one has already been included in another invoice') if existing_invoice_items.present?
      end

    end
  end


  # Calc amounts from the line items
  def set_amounts
    if self.invoice_items.present?
      self.total_amount_cents_exc_vat = self.invoice_items.collect(&:amount_cents_incl_quantity).sum

      if self.vat_rate.present?
        self.total_amount_cents_inc_vat = 0

        self.invoice_items.each do |invoice_item|
          if invoice_item.vat?
            self.total_amount_cents_inc_vat += ((self.vat_rate / 100) * invoice_item.amount_cents_incl_quantity) + invoice_item.amount_cents_incl_quantity
          else
            self.total_amount_cents_inc_vat += invoice_item.amount_cents_incl_quantity
          end
        end
      else
        self.total_amount_cents_inc_vat = self.total_amount_cents_exc_vat
      end
    else
      self.total_amount_cents_exc_vat = 0
      self.total_amount_cents_inc_vat = 0
    end
  end
  
  
  #
  # Cache amounts in accounts default currency
  def set_default_currency_amounts
    if self.project.present?
      if self.exchange_rate.present? && self.exchange_rate == 1.0
        
        # Set invoice items
        self.invoice_items.each do |invoice_item|
          invoice_item.default_currency_amount_cents = invoice_item.amount_cents
        end
        
        # Set invoice
        self.default_currency_total_amount_cents_exc_vat = self.total_amount_cents_exc_vat
        self.default_currency_total_amount_cents_inc_vat = self.total_amount_cents_inc_vat
      else
        account_default_currency = self.project.account.account_setting.default_currency
        reverse_exchange_rate = Currency.get_exchange_for(self.currency, account_default_currency)
        Money.add_rate(self.currency, account_default_currency, reverse_exchange_rate)
        
        # Set invoice items
        self.invoice_items.each do |invoice_item|
          invoice_item.default_currency_amount_cents = Money.new(invoice_item.amount_cents, self.currency).exchange_to(account_default_currency).cents
        end
        
        # Set invoice default amounts from the invoice items so amoutns match.
        self.default_currency_total_amount_cents_exc_vat = self.invoice_items.collect(&:default_currency_amount_cents_incl_quantity).sum
        self.default_currency_total_amount_cents_inc_vat = self.invoice_items.collect{|invoice_item| invoice_item.vat? ? ((self.vat_rate / 100) * invoice_item.default_currency_amount_cents_incl_quantity) + invoice_item.default_currency_amount_cents_incl_quantity : invoice_item.default_currency_amount_cents_incl_quantity}.sum
      end
    end
  end


  # Get exchange rate for your defualt currency and the invoice currency at the time the invoice was created
  def set_exchange_rate
    if self.project.present?
      self.exchange_rate = Currency.get_exchange_for(self.project.account.account_setting.default_currency, self.currency)
    end
  end
  
  
  # Sends an email to a given user if configured in settings to alert about the new invoice
  def send_alert_email
    if self.project.present?
      if self.project.account.account_setting.invoice_alert_email.present?
        InvoiceMailer.invoice_raised(self, self.project.account.account_setting.invoice_alert_email).deliver
      end
    end
  end
  
  
end

