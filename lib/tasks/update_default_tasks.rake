namespace :default_tasks do

  task(:update => :environment) do
    Account.all.each do |account|
      puts "* Creating new common tasks for #{ account.site_address }"
      project = account.projects.find_by_name 'Common tasks'
      if project.present?
        project.tasks.create!(:name => 'General Admin')
        project.tasks.create!(:name => 'Internal Meeting')
        puts "** Created new common tasks for #{ account.site_address }"
      end
    end
  end

end