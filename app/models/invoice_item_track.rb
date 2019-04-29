class InvoiceItemTrack


  # External libs
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming


  # Validation
  validates :start_date, :end_date, :payment_profile_id, :project_id, :presence => true
  validate :check_dates_are_valid
  validate :check_associated
  validate :data_exists_for_time_period


  # Virtual attr's
  attr_accessor :start_date, :end_date, :payment_profile_id, :project_id, :currency


#
# Save
#


  # Generate an invoice item based on the values set
  def generate_invoice_items
    if self.project_id.present? && self.payment_profile_id.present? && @start_date.present? && @end_date.present?
      project = Project.find(self.project_id)
      payment_profile = PaymentProfile.find(self.payment_profile_id)
      total_cost_cents = 0;

      default_currency = project.account.account_setting.default_currency
      invoice_currency = self.currency || project.account.account_setting.default_currency

      # Get mins tracked
      mins_tracked = Timing.minute_duration_submitted_for_period_by_project(project.id, @start_date, @end_date)

      # Generate cost
      if payment_profile.rate_card_payment_profiles.present?
        payment_profile.rate_card_payment_profiles.each do |rate_card_payment_profile|
          cost_per_min = rate_card_payment_profile.rate_card.cost_per_min_for_client(project.client_id, project.account)
          mins_for_rate_card = (mins_tracked / 100.0) * rate_card_payment_profile.percentage
          total_cost_cents += mins_for_rate_card * cost_per_min
        end
      end

      # Create new invoice item with correct values
      invoice_item_instance = InvoiceItem.new(:quantity => 1, :name => payment_profile.name, :payment_profile_id => payment_profile.id)
      invoice_item_instance.amount_cents = Currency.convert_amount(default_currency, invoice_currency, total_cost_cents)
      return invoice_item_instance
    end
    nil
  end


#
# General
#


  # Set the defaults
  def set_defaults
      @start_date = Date.today - 2.weeks
      @end_date = Date.today
  end


#
# Requirements to make form_for to work
#


  #
  def initialize(attributes = {})
    attributes.each do |name, value|
      if name.to_s != 'start_date' && name.to_s != 'end_date'
        send("#{name}=", value)
      else
        send("#{name}=", convert_date(value))
      end
    end
  end


  def persisted?
    false
  end


protected


  # See if any data for the given date period exists for this project
  def data_exists_for_time_period
    if self.project_id.present? && @start_date.present? && @end_date.present?
      project = Project.find(self.project_id)
      mins_tracked = Timing.minute_duration_submitted_for_period_by_project(project.id, @start_date, @end_date)
      errors.add(:base, "No submitted tracked time can be found for the provided date range") if mins_tracked == 0
    end
  end


  # Validation to chec that the dates provided are valid
  def check_dates_are_valid
    if @start_date.present? && @end_date.present?
      errors.add(:end_date, "can't be before the start date") if @end_date < @start_date
    end
  end


  # Check to see that the given payment profile id belongs to the same project
  def check_associated
    if self.project_id.present? && self.payment_profile_id.present?
      project = Project.find(self.project_id)
      payment_profile = PaymentProfile.find(self.payment_profile_id)

      self.errors.add(:base, 'Payment stages must belong to the current project') if project.id != payment_profile.project_id
    end
  end


  # Convert string to date object
  def convert_date(value)
    begin
      return Date.parse(value)
    rescue
      return nil
    end
  end
end

