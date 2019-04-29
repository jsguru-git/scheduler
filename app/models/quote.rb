class Quote < ActiveRecord::Base
  
  
  # External libs
  include SharedMethods
  

  # Relationships
  belongs_to :project, touch: true
  belongs_to :user
  belongs_to :parent_quote, :class_name => "Quote", :foreign_key => 'quote_id'
  has_many :version_quotes, :class_name => "Quote", :foreign_key => 'quote_id', :dependent => :nullify
  has_many :quote_activities, :dependent => :destroy
  has_many :quote_sections, :dependent => :destroy
  belongs_to :last_saved_by, :foreign_key => 'last_saved_by_id', :class_name => 'User'
  
  
  # Validation
  validates :quote_status, :presence => true, :inclusion => 0..3
  validates :vat_rate, :discount_percentage, :numericality => {:only_integer => false, :greater_than => -0.01, :less_than => 100.01}, :allow_blank => true, :presence => true
  validates :extra_cost_cents, :numericality => {:only_integer => true, :greater_than => -1}, :allow_blank => true
  validates :extra_cost_title, :presence => true, :if =>  Proc.new { |quote| quote.extra_cost_cents.present? && quote.extra_cost_cents > 0 }
  validate :check_associated
  validate :parent_quote_should_be_a_v1_quote
  validate :currency_should_be_in_supported
  
  
  # Callbacks
  before_validation :set_title_or_quote_id_to_nil
  before_validation :remove_whitespace
  after_save :updated_cached_exchange_rate
  after_update :set_to_live
  after_touch :set_to_live
  
  
  # Mass assignment protection
  attr_accessible :title, :currency, :vat_rate, :discount_percentage, :new_quote, :quote_id, :po_number, :quote_status, :currency, :extra_cost, :extra_cost_title


  # Virtual attr's
  attr_accessor :extra_cost


  # Plugins


#
# Extract functions
#


  # Named scopes
  scope :v1_quotes, where(['quotes.new_quote = ?', true])
  scope :date_created_ordered, order('quotes.created_at')
  scope :name_ordered, order('quotes.title')
  scope :live, where(['quotes.draft = ?', false])


  # Extract a display title
  def display_title
    if !self.new_quote? && self.parent_quote.present?
      self.parent_quote.display_title + " - v#{self.version_number}"
    elsif self.new_quote? && self.title.present?
      self.title
    else
      'No title'
    end
  end
  
  
  # Version number for the quote
  def version_number
    if !self.new_quote?
      version = 1
      self.parent_quote.version_quotes.date_created_ordered.each do |quote_instance|
        version +=1
        return "#{version}.0" if self.id == quote_instance.id
      end
    end
    '1.0'
  end
  
  
  # Get the previous quote verison
  def get_previous_quote_version
    if !self.new_quote? && self.parent_quote.present?
      self.parent_quote.version_quotes.date_created_ordered.each_with_index do |quote, index|
        if self.id == quote.id
          if index == 0
            return self.parent_quote
          else
            return self.parent_quote.version_quotes.date_created_ordered[index - 1]
          end
        end
      end
    end

    return nil
  end
  
  
  # Get the parent quote if exists, else return self
  def get_origional_quote
    if self.parent_quote.present?
      self.parent_quote
    else
      self
    end
  end
  
  
  # Min cost excl any discount and vat in cents
  def total_min_cost_ex_discount_and_vat_cents
    amount = self.quote_activities.sum(:min_amount_cents)
    amount += self.extra_cost_cents if self.extra_cost_cents.present?
    amount
  end
  
  
  # Max cost excl any discount and vat in cents
  def total_max_cost_ex_discount_and_vat_cents
    amount = self.quote_activities.sum(:max_amount_cents)
    amount += self.extra_cost_cents if self.extra_cost_cents.present?
    amount
  end
  
  
  # Min cost incl any discount and vat in cents
  def total_min_cost_incl_discount_and_vat_cents
    total = self.total_min_cost_ex_discount_and_vat_cents
    # Apply discount
    total = total - self.calculate_discount_for(total)
    # Apply VAT
    total =  total + self.calculate_tax_for(total)
    
    total.to_i
  end
  
  
  # Max cost incl any discount and vat in cents
  def total_max_cost_incl_discount_and_vat_cents
    total = self.total_max_cost_ex_discount_and_vat_cents
    # Apply discount
    total = total - self.calculate_discount_for(total)
    # Apply VAT
    total =  total + self.calculate_tax_for(total)
    
    total.to_i
  end
  
  
  # Min cost excl any discount and vat in cents in the given report currency
  def total_min_cost_excl_discount_and_vat_cents_in_report_currency
    # Calc each activity sepearatly to avoid rounding differences in totals
    self.quote_activities.sum(&:min_amount_cents_in_report_currency) + self.extra_cost_cents_in_report_currency
  end
  
  
  # Max cost excl any discount and vat in cents in the given report currency
  def total_max_cost_excl_discount_and_vat_cents_in_report_currency
    # Calc each activity sepearatly to avoid rounding differences in totals
    self.quote_activities.sum(&:max_amount_cents_in_report_currency) + self.extra_cost_cents_in_report_currency
  end
  
  
  # Min cost incl any discount and vat in cents in the given report currency
  def total_min_cost_incl_discount_and_vat_cents_in_report_currency
    total = self.total_min_cost_excl_discount_and_vat_cents_in_report_currency
    # Apply discount
    total = total - self.calculate_discount_for(total)
    # Apply VAT
    total =  total + self.calculate_tax_for(total)
    
    total.to_i
  end
  
  
  # Max cost incl any discount and vat in cents in the given report currency
  def total_max_cost_incl_discount_and_vat_cents_in_report_currency
    total = self.total_max_cost_excl_discount_and_vat_cents_in_report_currency
    # Apply discount
    total = total - self.calculate_discount_for(total)
    # Apply VAT
    total =  total + self.calculate_tax_for(total)
    
    total.to_i
  end


  # Get the exchange rate for default currency to report currency
  def report_currency_exchange_rate
    # If exchange reate has been locked use that
    if self.exchange_rate.present?
      self.exchange_rate
    else
      Currency.get_exchange_for(self.project.account.account_setting.default_currency, self.currency)
    end
  end
  
  
  # Get the most sutitable currency exchange rate
  def get_exchange_rate_updated_at
    if self.exchange_rate.present?
      self.exchange_rate_updated_at
    else
      to_currency = Currency.find_by_iso_code(self.currency)
      to_currency.updated_at
    end
  end
  
  
  # Search quotes
  def self.search(account, params)
    a_conditions = []
    a_conditions << ["projects.account_id = ?", account.id]
    a_conditions << ["quotes.new_quote = ?", true]
    
    # project name
    a_conditions << ["quotes.title LIKE ?", params[:title] + '%'] if params[:title].present?

    # client
    a_conditions << ["projects.client_id = ?", params[:client_id]] if params[:client_id].present?
    
    Quote.where([a_conditions.transpose.first.join(' AND '), *a_conditions.transpose.last]).includes([:project])
           .paginate(:page => params[:page], :per_page => APP_CONFIG['pagination']['site_pagination_per_page'])
           .order('quotes.title')
    
  end
  
  
  # Remove trailing 0's
  def vat_rate_out
    vat_rate.to_s.sub(/(?:(\..*[^0])0+|\.0+)$/, '\1')
  end
    
    
  # Remove trailing 0's
  def discount_percentage_out
    discount_percentage.to_s.sub(/(?:(\..*[^0])0+|\.0+)$/, '\1')
  end


#
# Save functions
#


  # Returns:
  # Copied - a number representing what has happened (see SELECTIONS['quote_copy_reasons'] for reason definitions)
  # Copy all activities from the previous quote
  def copy_activities_from_previous_quote
    copied = 0
    prev_quote = self.get_previous_quote_version
    
    if prev_quote.present?
      if prev_quote.quote_activities.present?
        
        # Remove all existing activities
        self.quote_activities.destroy_all
        
        # Copy previous activities over
        prev_quote.quote_activities.position_ordered.each do |activity|
          new_activity = activity.dup
          new_activity.position = nil
          new_activity.quote_id = self.id
          new_activity.save!
        end
        copied = 2
      else
        copied = 1
      end
    end
    
    copied
  end
  
  
  # Sets the last saved by to a given user
  def update_last_saved_by_to(user)
    self.last_saved_by_id = user.id
    self.save!
  end
  

#
# Create functions
#


  # Set the defaults
  def set_defaults
    if self.project.present?
      self.currency = self.project.account.account_setting.default_currency
    end
    
    self.quote_status = 0
    self.vat_rate = 20.0
    self.discount_percentage = 0.0
    self.new_quote = 1
  end


  # summary, further_information, disclaimer, content divider
  def create_default_sections!
    if self.project.present?
      account = self.project.account
      account.quote_default_sections.position_ordered.each do |quote_default_section|
        section = self.quote_sections.new(title: quote_default_section.title, content: quote_default_section.content)
        section.cost_section = quote_default_section.cost_section
        section.save!
      end
    end
  end
  
  
#
# Update functions
#


#
# Delete functions
#


  # Public: Deletes all draft quotes that are 1 day old
  def self.delete_old_draft_quotes
    quotes = Quote.where(["draft = ? AND created_at < ?", true, 1.day.ago])
    quotes.each do |quote|
      quote.destroy
    end
  end


#
# General functions
#
  
  
  # Output the extra cost in the quote report currency
  def extra_cost_cents_in_report_currency
    if self.extra_cost_cents.present?
      Currency.convert_amount(self.project.account.account_setting.default_currency, self.currency, self.extra_cost_cents, self.report_currency_exchange_rate)
    else
      0
    end
  end
  
  
  # Expected cost in dollers or equivalent
  def extra_cost
    if extra_cost_cents.present?
      read_attribute(:extra_cost_cents) / 100.0
    else
      0
    end
  end
  
  
  # Set the cents when the doller equivalent is set
  def extra_cost=(amount_dollars)
    if amount_dollars.present?
      write_attribute(:extra_cost_cents, (amount_dollars.to_s.to_d * 100).to_i)
    else
      write_attribute(:extra_cost_cents, 0)
    end
  end
  

  # Checks to see if the quote is editable
  def editable?
    if self.is_latest_version? && self.quote_status == 0
      true
    else
      false
    end
  end
  
  
  # Checks to see if the given quote instance is the latest version
  def is_latest_version?
    if self.new_quote?
      first = self
    else
      first = self.parent_quote
    end
    
    if first.version_quotes.blank?
      return true
    elsif first.version_quotes.date_created_ordered.last.id == self.id
      return true
    else
      return false
    end
  end
  
  
  # Check to see if quote includes any ranges
  def include_range_estimates?
    self.quote_activities.where(["estimate_type = ?", 1]).exists?
  end


protected


#
# Extract functions
#


  # Calculate the discount for a given amount
  def calculate_discount_for(total)
    if self.discount_percentage.present? && self.discount_percentage != 0.0
      (total / 100) * self.discount_percentage.round(2)
    else
      0
    end
  end


  # Calculate the tax for a given amount
  def calculate_tax_for(total)
    if self.vat_rate.present? && self.vat_rate != 0.0
      ((self.vat_rate / 100) * total)
    else
      0
    end
  end
  

#
# Save functions
#

  
  # Set the quote value to nil depending on if quote is a new quote or a version of an existing quote
  def set_title_or_quote_id_to_nil
    if self.new_quote?
      self.quote_id = nil
    else
      self.title = nil
    end
  end
  
  
  # Update the cached exchange rate if the project is not in progress and its not been set before
  def updated_cached_exchange_rate
    if self.quote_status == 0
      self.exchange_rate = nil
      self.exchange_rate_updated_at = nil
    else
      if self.exchange_rate.blank?
        to_currency = Currency.find_by_iso_code(self.currency)
        self.exchange_rate = Currency.get_exchange_for(self.project.account.account_setting.default_currency, self.currency)
        self.exchange_rate_updated_at = to_currency.updated_at
      end
    end
  end
  
  
#
# Validation functions
#
  
  
  # Check the associations all belong to the same account / project
  def check_associated
    if self.quote_id.present?
      errors.add(:quote_id, "must belong to the same project") if self.project_id != self.parent_quote.project_id
    end
    
    if self.user_id.present?
      errors.add(:user_id, "must belong to the same account") if self.project.account_id != self.user.account_id
    end
    
    if self.last_saved_by_id.present?
      errors.add(:last_saved_by_id, "must belong to the same account") if self.project.account_id != self.last_saved_by.account_id
    end
  end
  
  
  # Check chosen currency is supported
  def currency_should_be_in_supported
    self.errors.add(:currency, 'exchange rate can not be found and is not supported') if self.currency.present? && !Currency.exists?(:iso_code => self.currency)
  end
  
  
  # Checks parent quote is always a v1 quote
  def parent_quote_should_be_a_v1_quote
    if self.quote_id.present?
      errors.add(:quote_id, "parent must be a v1 quote") if !self.parent_quote.new_quote?
    end
    
    if !self.new_quote? || self.quote_id.present?
      errors.add(:quote_id, "already has newer versions and therefore can't become a new version of a previous quote") if self.version_quotes.present?
    end
  end
  
  
  # Protected: Set a project to live if it isnt already
  def set_to_live
    # Checks it was created more than 5 seconds ago as there are updates on creation.
    if self.draft? && self.created_at < 5.seconds.ago
      self.draft = false
      self.save!(validate: false)
    end
  end

  
end
