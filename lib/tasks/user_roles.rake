namespace :user_roles do

  task(initialize_pundit_roles: :environment) do
    User.all.each do |user|
      if user.roles.blank?
        user.roles << Role.find_by_title('member')
        puts "** Applying role 'member' to user #{ user.id }."
      else
        puts "** User #{ user.id } already has a role (#{ user.roles.map(&:title) }). Skipping..."
      end
    end
  end

end