class AccountPlan < ActiveRecord::Base

  # External libs

  include SharedMethods

  # Relationships

  has_many :accounts, :dependent => :nullify

  # Validation

  validates :name, :price_in_cents, :chargify_product_handle, :chargify_product_number, :presence => true
  validates :chargify_product_handle, :chargify_product_number, :uniqueness => true
  validates :price_in_cents, :numericality => true, :allow_blank => true

  # Callbacks

  before_validation :remove_whitespace

  # Mass assignment protection

  attr_accessible

  # Named scopes

  scope :expensive_first, order('account_plans.price_in_cents DESC')
  scope :viewable, where(:show_plan => true)


  #
  # Returns a list of all columns that are used to limit the account
  def self.get_limit_model_types
    limit_types = []
    prefix = 'no_'

    AccountPlan.column_names.each do |name|
      limit_types << name[prefix.length, (name.length - prefix.length - 1)] if name[0, prefix.length] == prefix
    end

    return limit_types
  end

  
  # Check to see if plan is free or not
  def free_plan?
    self.price == 0
  end


  # Get price
  def price
    price_in_cents / 100
  end


  #
  # Chargify methods
  #


  #
  # The url to the chargify hosted page for the current instance
  def chargify_hosted_signup_page
    "https://#{APP_CONFIG['chargify']['subdomain']}.chargify.com/h/#{self.chargify_product_number}/subscriptions/new"
  end


  # Get the url of chargifys hosted signup page
  def chargify_hosted_signup_link(user)
    self.chargify_hosted_signup_page + "?first_name=#{user.firstname}&last_name=#{user.lastname}&email=#{user.email}&reference=#{user.account.id}"
  end


  #
  # Pulls across all plan details from chargify and stores them locally
  def self.update_plan_details_from_chargify
    products = Chargify::Product.find(:all)

    products.each do |product|
      # Updating or creating new
      account_plan = AccountPlan.where(["chargify_product_handle = ?", product.handle]).first
      account_plan = AccountPlan.new if account_plan.blank?

      account_plan.name                    = product.name
      account_plan.description             = product.description
      account_plan.price_in_cents          = product.price_in_cents
      account_plan.chargify_product_handle = product.handle
      account_plan.chargify_product_number = product.id

      account_plan.save
    end
  end

end
