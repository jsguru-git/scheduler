require 'test_helper'

class Chargify::NotifiersControllerTest < ActionController::TestCase


    #
    # Confirmation
    test "confirmation via account after trial period" do
        get :confirmation, { :account_id => accounts(:accounts_001).id }
        assert_response :redirect
    end
end