namespace :api do

  # For each Fleetsuite user, if they don't already have an API key
  # assign one
  #
  task(:assign_keys => :environment) do
    User.all.each do |user|
      if user.api_key.nil?
        puts "Assigning API key to user #{user.id}"
        user.api_key = ApiKey.create!
      end
    end
  end
end
