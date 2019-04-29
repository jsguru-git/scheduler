class Task < ActiveRecord::Base

  # External libs
  include SharedMethods
  

  # Relationships
  belongs_to :project
  belongs_to :feature
  belongs_to :quote_activity
  belongs_to :rate_card
  has_many   :timings, :dependent => :restrict


  # Validation
  validates :project_id, :presence => true
  validates :estimated_minutes, :numericality => {:only_integer => true, :greater_than => -1}, :allow_blank => true
  validates :estimated, :numericality => {:only_integer => false, :greater_than => -0.01}, :allow_blank => true
  validates :estimate_scale, :numericality => {:only_integer => true, :greater_than => 0}, :allow_blank => true
  validates :name, :presence => true, :length => { :maximum => 255 }
  validates :description, :length => { :maximum => 2000 }
  validates :quote_activity_id, uniqueness: true, allow_nil: true
  validate  :check_associated


  # Callbacks
  before_validation :remove_whitespace
  before_validation :calc_estimate_from_form
  after_create :alert_unquoted_activity


  # Mass assignment protection
  attr_accessible :name, :description, :feature_id, :count_towards_time_worked, :estimated, :estimate_scale, :quote_activity_id, :rate_card_id, :estimated_minutes
  
  
  # Virtual attributes
  attr_accessor :estimated


  # Plugins
  acts_as_list :scope => 'project_id = #{project_id} AND feature_id #{feature_id.present? ? "= " + feature_id.to_s : "IS NULL"}'
  
  
#
# Extract functions
#


  # Named scopes
  scope :name_ordered, order('tasks.name')
  scope :position_ordered, order('tasks.position')
  scope :no_associated_feature, where(['feature_id IS ?', nil])


  # The total time tracked for a task in minutes
  #
  # Returns integer
  def time_tracked_minutes
    timings.sum(:duration_minutes)
  end
  
  # The total submitted time tracked for a task in minutes
  #
  # Returns integer
  def submitted_time_tracked_minutes
    timings.submitted_timings.sum(:duration_minutes)
  end


  # The time tracked in hours
  #
  # Returns integer
  def time_tracked
    time_tracked_minutes / 60
  end


  # A string in the format xx hours yy minutes
  #
  #
  def time_tracked_as_string
    hours = time_tracked_minutes / 60
    minutes = time_tracked_minutes % 60
    "#{hours} hours #{minutes} minutes"
  end

  # Public: Sentence for how long a Task has been estimated
  #
  # Returns a String in the format xx hours yy minutes
  def time_estimated_as_string
    hours = estimated_minutes / 60
    minutes = estimated_minutes % 60
    "#{ hours } hours #{ minutes } minutes"
  end


  # Helper function that returns the minutes worked on a taks this month
  #
  # Returns integer
  def time_this_month
    results = timings.where(["created_at >= ?", 1.month.ago])
    results.sum(:duration_minutes)
  end
  
  
  # Work out the amount of full hours (max)
  def estimated_out
    if estimated_minutes.present?
      if self.respond_to? :account
        acc_settings = self.account.account_setting
      else
        acc_settings = self.project.account.account_setting
      end

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
      (read_attribute(:estimated_minutes) / divide_value.to_s.to_d).round(2)
    end
  end
  
  
  def self.total_estimated_minutes_for_client(client_id)
    Task.where(['projects.client_id = ?', client_id]).includes(:project).sum(:estimated_minutes)
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


  protected

  def alert_unquoted_activity
    unless quote_activity || project.name == 'Common tasks'
      ProjectMailer.unquoted_activity_email(self).deliver
    end
  end

  #
  # Check to see that the given feature id belongs to the correct project
  def check_associated
    if self.feature_id.present? && self.project.present?
      errors.add(:feature_id, "does not exist") unless self.project.features.exists?(self.feature_id)
    end
  end
  
  
  
  # Takes the virtual attribtues and converts them to minutes for storage based on the scale that is being used
  def calc_estimate_from_form
    # Only perform calulation if we pass in some data
    if self.estimated.present?
      self.estimated_minutes = 0
      if self.respond_to? :account
        acc_settings = self.account.account_setting
      else
        acc_settings = self.project.account.account_setting
      end
      
      # Convert to decimal
      self.estimated = self.estimated.to_s.to_d.round(2)

      if acc_settings.present?
        if self.estimate_scale == 1
          # Days
          mins_per_day = acc_settings.working_day_duration_minutes
          self.estimated_minutes = (self.estimated*mins_per_day).to_i if self.estimated.present?
        elsif self.estimate_scale == 2
          # Weeks
          mins_worked_in_week = acc_settings.number_of_minutes_worked_in_a_week
          self.estimated_minutes = (self.estimated*mins_worked_in_week).to_i if self.estimated.present?
        elsif self.estimate_scale == 3
          # Months
          mins_worked_in_month = acc_settings.number_of_minutes_worked_in_a_month
          self.estimated_minutes = (self.estimated*mins_worked_in_month).to_i if self.estimated.present?
        end
      end
    end
  end
  

#
# Destroy methods
#


end
