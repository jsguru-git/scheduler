# Utility methods for the Fleetsuite API

module Api

  # Class for calculating internal dashboard metrics
  #
  class Internal

    class << self
      # Returns JSON
      def get_capacity(params, account)
        team, start, end_date = fetch_data_from_params(params, account)
        data = fetch_data(team, start, end_date)
        total_capacity = get_total_capacity(data)
        {:data => data, :total => total_capacity}
      end

      # Given http request params, extract the team, start and end date
      #
      # Returns an array
      def fetch_data_from_params(params, account)
        team = account.teams.find(params[:team])
        start = Date.parse(params[:start_date])
        end_date = Date.parse(params[:end_date])
        [team, start, end_date]
      end

      # Fetches the important API metrics for a given team
      def fetch_data(team, start, end_date)
        team.users.map do |u|
          { capacity: u.capacity(start, end_date),
            gravatar: u.gravatar_url,
            name:     u.name }
        end
      end

      # Calculates the total capacity for a given team
      def get_total_capacity(data)
        potential_capacity = data.size * 100
        actual_capacity = data.map { |h| h[:capacity] }.sum
        total = (actual_capacity / potential_capacity.to_f) * 100
        total.to_i
      end
    end
  end
end

