# ==============================================
#
# Quick application boostrapping
#
# ==============================================

def copy_database_yml
  unless File.exists?("config/database.yml")
    puts "Copying database.yml..."
    system "cp config/database-sample.yml config/database.yml"
  end
end

def update_bundler
  puts "Updating Gems..."
  system "bundler"
end

def update_database
  puts "Updating database..."
  system "bundle exec rake db:migrate && rake db:test:prepare"
end

def build_database
  puts "Building database..."
  system "bundle exec rake db:create && rake db:migrate && rake db:test:prepare"
end

def import_chargify
  puts "Importing products from Chargify..."
  system "rake chargify:import_all_product_details"
end

def start_server(port)
  puts "Starting server on port #{port}..."
  system "rails s -p #{port}"
end

namespace :bootstrap do

  desc "Setup the application from scratch"
  task :setup => :environment do
    if Rails.env.development?
      puts "Installing application..."
      copy_database_yml
      update_bundler
      build_database
      import_chargify
      start_server(4567)
    else
      raise "You can only run this task in development environment"
    end
  end

  desc "Update an existing application (perhaps from a fresh git pull etc)"
  task :update => :environment do
    if Rails.env.development?
      copy_database_yml
      update_bundler
      update_database
      start_server(4567)
    else
      raise "You can only run this task in development environment"
    end
  end
end
