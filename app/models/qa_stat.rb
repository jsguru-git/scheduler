require 'jira_wrapper'

class QaStat < ActiveRecord::Base
  
  
  # External libs
  

  # Relationships
  belongs_to :project


  # Validation
  validates :project_id, :total_tickets, presence: true


  # Callbacks


  # Mass assignment protection
  attr_accessible :ticket_breakdown, :total_tickets
  
  
  # Serialize
  serialize :ticket_breakdown, Hash


  # Plugins


#
# Extract functions
#


  # Named scopes
  


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


  # Public: Get all column headings for an array of qa stats
  #
  # qa_stats {Array} array of qa stat instances
  # group {Symbol} which heading group to look at
  def self.get_all_column_headings_for(qa_stats, group)
    headings = []
    if qa_stats.present? && qa_stats.length > 0
      qa_stats.each do |qa_stat|
        if qa_stat.ticket_breakdown[group].present?
          qa_stat.ticket_breakdown[group].each do |key, value|
            headings << key if !headings.include? key
          end
        end
      end
    end
    headings
  end

  # Public: Pull the latest data from issue trackers
  def self.pull_lastest_data_from_issue_tracker
    Project.not_closed.where(["issue_tracker_id IS NOT ?", nil]).find_each do |project|
      issue_tracker = IssueTracker::JiraWrapper.new(project.account.account_setting)
      stats = issue_tracker.get_issue_count_for_project(project.issue_tracker_id)
      if stats.present?
        project.qa_stats.create!(ticket_breakdown: stats, total_tickets: stats[:total])
      end
    end
  end


protected


end
