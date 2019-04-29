require 'test_helper'

class Reports::TasksControllerTest < ActionController::TestCase
  
  def setup
    change_host_to(:accounts_001)
    login_as(:users_001)
    @permitted = [:account_holder, :administrator, :leader]
  end

end
