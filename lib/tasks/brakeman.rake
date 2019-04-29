# Run brakeman tests on Jenkins

# require 'brakeman'

namespace :brakeman do
  desc "Run brakeman via shell"
  task :run_shell do
    system "gem update brakeman --no-ri --no-rdoc &&
            brakeman -o brakeman-output.tabs"
  end
end

