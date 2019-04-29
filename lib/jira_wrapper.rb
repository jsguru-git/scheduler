module IssueTracker
  
  require 'httparty'
  
  class JiraWrapper
  
    # required vars
    attr_reader :api_username, :api_password, :api_url, :app_url


    # libs
    include HTTParty


    # httparty config
    format :json


    # Public: Initialize
    #
    # auth {Hash} containing details of the issue tracker
    def initialize(account_setting)
        # basic auth details
        @api_username = account_setting.issue_tracker_username_raw
        @api_password = account_setting.issue_tracker_password_raw

        @api_url = "#{account_setting.issue_tracker_url}/rest/api/2"
        @app_url = account_setting.issue_tracker_url

        self.class.base_uri @api_url
        self.class.basic_auth @api_username, @api_password

        self.class.headers({'Content-Type' => 'application/json'})
    end


#
# Project
#


    # Public: Find a project
    #
    # id {String} Jira project key
    #
    # Returns: {Object} http response
    def project_find(id)
      begin
        response = self.class.get("/project/#{id}")
        if response.present? && response.code == 200
            return response
        else
            return nil
        end
      rescue Exception => exc
        Rails.logger.error("**** ERROR, FILE: jira_wrapper.rb, MESSAGE: #{exc.message}")
        return nil
      end
    end


    # Public: Check if a project exists
    #
    # id {String} Jira project key
    def project_exists?(id)
      response = self.project_find(id)
      if !response.blank? && response.code == 200 && response['key'].present?
        true
      else
        false
      end
    end


#
# Tickets
#


    # Public: Return list of issue count for a given project
    #
    # id {String} Jira project key
    #
    # Returns {Hash} Issue counts
    def get_issue_count_for_project(id)
      h_issues = {total: 0, status: {}, priority: {}}
      
      begin
        start = 0
        
        while true
          response = self.get_all_issues(id, start)
          if response.present? && response['issues'].present?
            response['issues'].each do |issue|
              
              # Only capture bugs
              if issue['fields'].present? && issue['fields']['issuetype'].present? && issue['fields']['issuetype']['name'].present? && issue['fields']['issuetype']['name'].downcase == 'bug'
                h_issues[:total] += 1
                # Store status
                if issue['fields'].present? && issue['fields']['status'].present? && issue['fields']['status']['name'].present?
                  if h_issues[:status].has_key?(issue['fields']['status']['name'])
                    h_issues[:status][issue['fields']['status']['name']] += 1
                  else
                    h_issues[:status][issue['fields']['status']['name']] = 1
                  end
                end
          
                # Store issue priority
                if issue['fields'].present? && issue['fields']['priority'].present? && issue['fields']['priority']['name'].present?
                  if h_issues[:priority].has_key?(issue['fields']['priority']['name'])
                    h_issues[:priority][issue['fields']['priority']['name']] += 1
                  else
                    h_issues[:priority][issue['fields']['priority']['name']] = 1
                  end
                end
              end
              
            end
          else
            return h_issues
          end
          
          # Move to next result page
          start = response['startAt'].to_i + 100
          break if start > response['total'].to_i
        end
        
        h_issues
      rescue Exception => exc
        Rails.logger.error("**** ERROR, FILE: jira_wrapper.rb, MESSAGE: #{exc.message}")
        return nil
      end
    end


protected

  
    # Protected: Get all issues for the given project
    #
    # id {String} Jira project key
    # start {Integer} The record to start at
    #
    # Returns {Object} http response
    def get_all_issues(id, start = 0)
      begin
        response = self.class.get("/search?jql=project=#{id}&maxResults=100&startAt=#{start}")
        if response.present? && response.code == 200
            return response
        else
            return nil
        end
      rescue Exception => exc
        Rails.logger.error("**** ERROR, FILE: jira_wrapper.rb, MESSAGE: #{exc.message}")
        return nil
      end
    end
  

  end
end