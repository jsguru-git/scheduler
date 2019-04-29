# Methods to help with min & max estimation figures (used in project, feature, task)
module EstimateTime


  # includes
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.extend(ClassMethods)

    # Validaitons
    base.validates :min_estimated_minutes, :max_estimated_minutes,  :numericality => {:only_integer => true, :greater_than => -1, :allow_blank => true}
    base.validates :min_estimated, :max_estimated, :numericality => {:only_integer => false, :greater_than => -0.01}, :allow_blank => true
    base.validates :estimate_scale,  :numericality => {:only_integer => true, :greater_than => 0, :allow_blank => true, :presence => true}
    base.validate  :min_is_less_than_max_estimate


    # Callbacks
    base.before_validation :calc_estimate_from_form


    # Mass assignment protection
    base.attr_accessible :min_estimated, :max_estimated, :estimate_scale
  end
  
  
  # Instance method
  module InstanceMethods


    # Virtual attributes
    attr_accessor :min_estimated, :max_estimated


    #
    # Work out the amount of full hours (min)
    def min_estimated_out
      if min_estimated_minutes.present?
        acc_settings = self.get_account_settings

        if self.estimate_scale == 1
          # Days
          divide_value = acc_settings.working_day_duration_minutes
        elsif self.estimate_scale == 2
          # Weeks
          divide_value = acc_settings.number_of_minutes_worked_in_a_week
        elsif self.estimate_scale == 3
          # Months
          divide_value = acc_settings.number_of_minutes_worked_in_a_month
        end
        (read_attribute(:min_estimated_minutes) / divide_value.to_s.to_d).round(2)
      end
    end

    
    # Work out the amount of full hours (max)
    def max_estimated_out
        if max_estimated_minutes.present?
          acc_settings = self.get_account_settings

          if self.estimate_scale == 1
            # Days
            divide_value = acc_settings.working_day_duration_minutes
          elsif self.estimate_scale == 2
            # Weeks
            divide_value = acc_settings.number_of_minutes_worked_in_a_week
          elsif self.estimate_scale == 3
            # Months
            divide_value = acc_settings.number_of_minutes_worked_in_a_month
          end
          (read_attribute(:max_estimated_minutes) / divide_value.to_s.to_d).round(2)
        end
    end


  protected


    # Check that the min estimate is less than the max
    def min_is_less_than_max_estimate
      if self.min_estimated_minutes.present? && self.max_estimated_minutes.present?
        errors.add(:min_estimated_minutes, "must be less than the maximum")  if self.max_estimated_minutes < self.min_estimated_minutes
      end
    end


    # Takes the virtual attribtues and converts them to minutes for storage based on the scale that is being used
    def calc_estimate_from_form
      # Only perform calulation if we pass in some data
      if self.min_estimated.present? || self.max_estimated.present?
        self.min_estimated_minutes = 0
        self.max_estimated_minutes = 0
        acc_settings = self.get_account_settings
        
        # Convert to decimal
        self.min_estimated = self.min_estimated.to_s.to_d.round(2)
        self.max_estimated = self.max_estimated.to_s.to_d.round(2)
        
        if acc_settings.present?
          if self.estimate_scale == 1
            # Days
            mins_per_day = acc_settings.working_day_duration_minutes
            self.min_estimated_minutes = (self.min_estimated*mins_per_day).to_i if self.min_estimated.present?
            self.max_estimated_minutes = (self.max_estimated*mins_per_day).to_i if self.max_estimated.present?
          elsif self.estimate_scale == 2
            # Weeks
            mins_worked_in_week = acc_settings.number_of_minutes_worked_in_a_week
            self.min_estimated_minutes = (self.min_estimated*mins_worked_in_week).to_i if self.min_estimated.present?
            self.max_estimated_minutes = (self.max_estimated*mins_worked_in_week).to_i if self.max_estimated.present?
          elsif self.estimate_scale == 3
            # Months
            mins_worked_in_month = acc_settings.number_of_minutes_worked_in_a_month
            self.min_estimated_minutes = (self.min_estimated*mins_worked_in_month).to_i if self.min_estimated.present?
            self.max_estimated_minutes = (self.max_estimated*mins_worked_in_month).to_i if self.max_estimated.present?
          end
        end
      end
    end
    
    
    # Get the account settings for the given object
    def get_account_settings
        acc_settings = self.quote.project.account.account_setting
    end


  end


  # Class methods
  module ClassMethods
  end


end
