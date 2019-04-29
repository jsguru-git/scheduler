# ========================
#
# Runs all Jasmine specs
#
# rake javascript
#
# ========================

namespace :javascript do
  task :test => :environment do
    if Rails.env.development?
      system "bundle exec guard-jasmine"
    end
  end
end

task :javascript => :environment do
  Rake::Task['javascript:test'].invoke
end
