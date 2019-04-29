class AccountComponent < ActiveRecord::Base


  # External libs
  include SharedMethods


  # Relationships
  has_many :account_account_components, :dependent => :destroy
  has_many :accounts, :through => :account_account_components


  # Validation
  validates :name, :price_in_cents, :chargify_component_number, :presence => true
  validates :chargify_component_number, :uniqueness => true
  validates :price_in_cents, :chargify_component_number, :numericality => true, :allow_blank => true


  # Callbacks
  before_validation :remove_whitespace


  # Mass assignment protection
  attr_accessible


  # Named scopes
  scope :viewable, where(:show_component => true)
  scope :priority_order, order('priority')
  

  # enable component for a given account
  def enable_for(account)
    unless account.component_enabled?(self.id)
      self.enable_in_chargify_for(account)
      
      account.account_components << self
    end
  end
  
  
  # disable component for a given account
  def disable_for(account)
    if account.component_enabled?(self.id)
      self.disable_in_chargify_for(account)
      
      AccountAccountComponent.where(["account_id = ? AND account_component_id = ?", account.id, self.id]).delete_all
    end
  end


  #
  # Checks to see if the given component can be disabled. (can only be disabled if they dont have data)
  def can_component_be_disabled_for?(account)
    can_be_disabled = true

    if self.id == 1
      # Schedule
      can_be_disabled = false if account.entries.length > 0
    elsif self.id == 2
    # Track
      timing_count = Timing.includes([:project]).where(["projects.account_id = ?", account.id]).count
      can_be_disabled = false if timing_count > 0
    elsif self.id == 3
      # Quote
      quote_count = Quote.includes([:project]).where(["projects.account_id = ?", account.id]).count
      can_be_disabled = false if quote_count > 0
    elsif self.id == 4
      # Invoice
      invoice_count = Invoice.includes([:project]).where(["projects.account_id = ?", account.id]).count
      can_be_disabled = false if invoice_count > 0
    end

    return can_be_disabled
  end


#
# chargify functions
#


  #
  # Enable the component in chargify
  def enable_in_chargify_for(account)
    if !Rails.env.test? && account.chargify_customer_id.present?
      chargify_subscription = Chargify::Subscription.find_by_customer_reference(account.id)
      chargify_component = chargify_subscription.component(self.chargify_component_number)
      chargify_component.enabled = true
      chargify_component.save
    end
  end
  
  
  #
  # Disable the component in chargify
  def disable_in_chargify_for(account)
    if !Rails.env.test? && account.chargify_customer_id.present?
      chargify_subscription = Chargify::Subscription.find_by_customer_reference(account.id)
      chargify_component = chargify_subscription.component(self.chargify_component_number)
      chargify_component.enabled = false
      chargify_component.save
    end
  end


  def price
    price_in_cents / 100
  end


#
# Chargify methods
#


  #
  # pulls across all compnenet details from chargify and stores them locally
  def self.update_component_details_from_chargify
    product_family = Chargify::ProductFamily.find(:first)
    components = Chargify::Component.find(:all, :params => {:product_family_id => product_family.id})

    components.each do |component|
      # Updating or creating new
      account_component = AccountComponent.where(["chargify_component_number = ?", component.id]).first
      account_component = AccountComponent.new if account_component.blank?

      account_component.name                      = component.name
      account_component.price_in_cents            = (component.unit_price * 100).to_i
      account_component.chargify_component_number = component.id

      account_component.save
    end
  end

end
