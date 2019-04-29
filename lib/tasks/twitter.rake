namespace :twitter do
  # Find the most recent tweets
  task(:find_tweets => :environment) do
    begin
      Tweet.get_tweets
    rescue Exception => e
      # Output exceptions
      puts e.message
    end
  end
end