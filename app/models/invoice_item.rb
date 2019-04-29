class InvoiceItem < ActiveRecord::Base


  # External libs
  include SharedMethods


  # Relationships
  belongs_to :invoice
  belongs_to :payment_profile


  # Validation
  validates :quantity, :name, :amount, :presence => true
  validates :amount_cents, :numericality => {:only_integer => true, :greater_than => -1}, :allow_blank => true
  validates :amount, :numericality => {:only_integer => false, :greater_than => -1}, :allow_blank => true


  # Callbacks
  before_validation :remove_whitespace
  after_create :create_payment_profile_if_required


  # Mass assignment protection
  attr_accessible :quantity, :vat, :name, :amount, :payment_profile_id


  # Virtual attr's
  attr_accessor :amount


  # Expected cost in dollars or equivalent
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
      write_attribute(:amount_cents, (amount_dollars.to_f * 100).to_i)
    else
      write_attribute(:amount_cents, 0)
    end
  end
  
  
  # Amount cents after quantity applied
  def amount_cents_incl_quantity
    self.amount_cents * self.quantity
  end


  # Default currency amount cents after quantity applied
  def default_currency_amount_cents_incl_quantity
    self.default_currency_amount_cents * self.quantity
  end
  

#
# Create functions
#


  #
  # Generate invoice items from payment profiles using the params passed in
  def self.generate_from_payment_profile(project, form_params)
    invoice_items = []

    # Check what currencies are in use
    default_currency = project.account.account_setting.default_currency
    invoice_currency = form_params[:currency] || project.account.account_setting.default_currency

    if form_params[:payment_profiles].present?
      form_params[:payment_profiles].each do |payment_profile_id|
        profile_instance = project.payment_profiles.find(payment_profile_id)

        # Create new invoice item with correct values
        invoice_item_instance = InvoiceItem.new(:quantity => 1, :name => profile_instance.name, :payment_profile_id => profile_instance.id)
        invoice_item_instance.amount_cents = Currency.convert_amount(default_currency, invoice_currency, profile_instance.expected_cost_cents)

        invoice_items << invoice_item_instance
      end
    end

    invoice_items
  end

protected


  # If invoice_item does not have an associated payment profile, create one
  def create_payment_profile_if_required
    if self.payment_profile.blank?
      project = self.invoice.project
      
      new_payment_profile = project.payment_profiles.new( 
        :name => self.name, 
        :expected_payment_date => self.invoice.invoice_date, 
        :generate_cost_from_time => false, 
        :expected_cost => (self.amount * self.quantity))
        
        
      new_payment_profile.save!
      self.payment_profile_id = new_payment_profile.id
      self.save!
    end
  end


end
