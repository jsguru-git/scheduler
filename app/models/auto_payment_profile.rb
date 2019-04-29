class AutoPaymentProfile
  
  
  # External libs
  include ActiveModel::Validations  
  include ActiveModel::Conversion  
  extend ActiveModel::Naming
  
  
  # Validation
  validates :start_date, :end_date, :presence => {:message => "can't be blank or must be a valid date"}
  validates :frequency, :presence => true, :inclusion => %w(0 1 2)
  validate :check_dates_are_valid
  
  
  # Virtual attr's
  attr_accessor :start_date, :end_date, :frequency
  
  
#
# Save
#
  
  
  # Create the required payment stages
  def create_payment_stages_for(project)
    created_payment_profiles = []
    while @start_date < @end_date do
      
      if frequency == '0'
        end_period = (@start_date + 1.month) - 1.day
      elsif frequency == '1'
        end_period = (@start_date + 2.weeks) - 1.day
      elsif frequency == '2'
        end_period = (@start_date + 1.week) - 1.day
      end
      
      # Check period end date is not greater than the provided end date
      end_period = @end_date if end_period > @end_date
      
      scheduled_days = Entry.get_number_of_days_scheduled_for_project_by_period(project, @start_date, end_period)
      
      # Create Payment stage
      created_payment_profiles = self.create_payment_profile_entry(project, scheduled_days, @start_date, end_period, created_payment_profiles)
      
      # Move on to next period
      if frequency == '0'
        @start_date += 1.month
      elsif frequency == '1'
        @start_date += 2.weeks
      elsif frequency == '2'
        @start_date += 1.week
      end
    end
    return created_payment_profiles
  end
  
  
  # Create an entry for the given date range and project
  def create_payment_profile_entry(project, scheduled_days, start_period, end_period, created_payment_profiles)
    if scheduled_days > 0
      new_payment_profile = project.payment_profiles.new
      new_payment_profile.attributes = {
        :name => "#{start_period.strftime("%d %b %Y")} - #{end_period.strftime("%d %b %Y")}", 
        :expected_payment_date => end_period, 
        :generate_cost_from_time => true, 
        :expected_days => scheduled_days
      }
      
      if new_payment_profile.save
        
        # Add service types too (Taken from project level) 
        # if project.rate_card_projects.present?
        #     project.rate_card_projects.each do |rate_card_project|
        #       new_payment_profile.rate_card_payment_profiles.new(:rate_card_id => rate_card_project.rate_card_id, :percentage => rate_card_project.percentage)
        #     end
        #     new_payment_profile.save!
        #   end
        
        # Add to return array
        created_payment_profiles << new_payment_profile
      end
    end
    created_payment_profiles
  end
  

#
# General
#

  
  # Check if its going to be possible to genearte a payment schedule
  def can_generate_from_scheulde_for(project)
    if project.entries.length > 0
      true
    else
      false
    end
  end
  
  
  # Set the defaults for this project
  def set_defaults_for(project)
    if self.can_generate_from_scheulde_for(project)
      project_entries = project.entries.start_date_ordered
      
      @start_date = project_entries.first.start_date
      @end_date = project_entries.last.end_date
      @end_date = @start_date + 1.month if (@start_date + 1.month) > @end_date # Always make sure there is at least a full month apart
      
      @frequency = '0'
    end
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


  #
  def persisted?  
    false  
  end
 
 
protected


  # Validation to chec that the dates provided are valid
  def check_dates_are_valid
    if @start_date.present? && @end_date.present?
      errors.add(:end_date, "can't be before the start date") if @end_date < @start_date
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