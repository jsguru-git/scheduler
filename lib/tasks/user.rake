namespace :user do
  desc "Create new account holder on all accounts"
  task(:create_account_holder => :environment) do
    puts "Creating users"
    Account.all.each do |account|
      password = Faker::Lorem.characters(6)
      user = account.users.new(email: 'fleetsuite@arthurly.com',
                      firstname: Faker::Name.first_name,
                      lastname: Faker::Name.last_name,
                      password: password,
                      password_confirmation: password)
      user.roles = [Role.where(title: 'account_holder').first]
      user.save
      puts "Created user for account ID #{ account.id }"
    end
  end

end