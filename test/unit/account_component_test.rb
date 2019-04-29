require 'test_helper'

class AccountComponentTest < ActiveSupport::TestCase

    test "should check price is calculated correctly" do
        assert_equal account_components(:one).price_in_cents / 100, account_components(:one).price
    end

    test "should check if component can be disabled" do
        assert_equal false, account_components(:one).can_component_be_disabled_for?(accounts(:accounts_001))
        assert account_components(:one).can_component_be_disabled_for?(accounts(:accounts_003))
    end

    test "should enable component" do
        assert_difference 'AccountAccountComponent.all.size', +1 do
            account_components(:one).enable_for(accounts(:accounts_002))
        end
    end

    test "should disable component" do
        accounts(:accounts_003).account_components << account_components(:one)
        
        assert_difference 'AccountAccountComponent.all.size', -1 do
            account_components(:one).disable_for(accounts(:accounts_003))
        end
    end    
end

