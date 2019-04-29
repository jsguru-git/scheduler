require 'test_helper'

class AccountTest < ActiveSupport::TestCase

    # validate uniqueness
    test "validates uniqnuess of site_address" do
        new_account = accounts(:accounts_001).dup
        new_account.site_address = 'jon'
        assert_equal new_account.valid?, false
    end

    # validate length
    test "site address length" do
        min = "a"
        max = 36.times.collect { "a" }.join
        blank = ""
    
        new_account = accounts(:accounts_001).dup
        
        new_account.site_address = min
        assert_equal new_account.valid?, false
        
        new_account.site_address = max
        assert_equal new_account.valid?, false

        new_account.site_address = blank
        assert_equal new_account.valid?, false
    end

    # validate exclusion
    test "cannot use reserved subdomains" do
        RESERVED_SUBDOMAINS.each do |subdomain|
            new_account = accounts(:accounts_001).dup
            new_account.site_address = subdomain
            assert_equal new_account.valid?, false
        end
    end

    # validate uniqueness
    test "validates correct chars used for site_address" do
        new_account = accounts(:accounts_001).dup
        new_account.site_address = 'jon*(test'
        assert_equal new_account.valid?, false
        assert new_account.errors[:site_address].present?
    end

    test "finds an active account" do
        assert_equal Account.find_active_account('ruby'), accounts(:accounts_001)
    end

    test "doesnt find an inactive account" do
        assert_equal Account.find_active_account(''), nil
        assert_equal Account.find_active_account('accounts_004'), nil
    end

    # site_address=
    test "downcases and updates the site address" do
        accounts(:accounts_004).site_address = "DOWNCASEME"
        accounts(:accounts_004).save
        assert_equal accounts(:accounts_004).site_address, "downcaseme"
    end

    test "first_login?" do
        assert_equal accounts(:accounts_002).first_login?, true
        assert_equal users(:users_001).account.first_login?, false
    end

    # update_plan_by_handle
    test "update_plan_by_handle" do
        accounts(:accounts_001).update_plan_by_handle("basic")
        assert_equal accounts(:accounts_001).account_plan.chargify_product_handle, "basic"
    end

    test "should update plan" do
        updated = accounts(:accounts_003).update_plan_to(1)
        assert updated
        assert_equal 1, accounts(:accounts_003).account_plan_id
    end

    test "should check if account has exceeded the plan limits" do
        accounts(:accounts_001).account_plan.no_users = accounts(:accounts_001).users.length + 1
        assert_equal false, accounts(:accounts_001).exceeded_limit?

        accounts(:accounts_001).account_plan.no_users = accounts(:accounts_001).users.length
        assert_equal false, accounts(:accounts_001).exceeded_limit?

        accounts(:accounts_001).account_plan.no_users = accounts(:accounts_001).users.length - 1
        assert_equal true, accounts(:accounts_001).exceeded_limit?
    end

    test "should check if account has reached the plan limits" do
        accounts(:accounts_001).account_plan.no_users = accounts(:accounts_001).users.length + 1
        assert_equal false, accounts(:accounts_001).reached_limit?

        accounts(:accounts_001).account_plan.no_users = accounts(:accounts_001).users.length
        assert_equal true, accounts(:accounts_001).reached_limit?

        accounts(:accounts_001).account_plan.no_users = accounts(:accounts_001).users.length - 1
        assert_equal true, accounts(:accounts_001).reached_limit?
    end

    test "should set trial_expires_at on creation" do
        valid_params = valid_new_params
        account = Account.new(valid_params)
        account.account_plan_id = 1
        assert_difference 'Account.all.size', +1 do
            account.save!
        end
        assert_not_nil account.trial_expires_at
        assert account.trial_expires_at > Time.now
    end

    test "should suspend accounts with expired 30 day trials" do
        valid_params = valid_new_params
        account = Account.new(valid_params)
        account.account_plan_id = 1
        account.save!
        account.trial_expires_at = 1.day.ago
        account.save!
        
        valid_params = valid_new_params.merge(:site_address => 'asdfasdfsa')
        account2 = Account.new(valid_params)
        account2.account_plan_id = 1
        account2.save!
        account2.trial_expires_at = 1.day.from_now
        account2.save!
        
        Account.delete_expired_trial_accounts
        account.reload
        
        assert_equal false, account2.account_suspended
        assert account.account_suspended
    end

    test "should delete accounts with expired 30 day trials" do
        valid_params = valid_new_params
        account = Account.new(valid_params)
        account.account_plan_id = 1
        account.save!
        account.trial_expires_at = 15.day.ago
        account.save!
        
        valid_params = valid_new_params.merge(:site_address => 'asdfasdfsa')
        account2 = Account.new(valid_params)
        account2.account_plan_id = 1
        account2.save!
        account2.trial_expires_at = 13.day.ago
        account2.save!
        
        Account.delete_expired_trial_accounts
        account.reload
        
        assert_nil account2.account_deleted_at
        assert_not_nil account.account_deleted_at
    end

    test "should remove accounts that have been canceled" do
        accounts(:accounts_003).account_deleted_at = 11.weeks.ago
        accounts(:accounts_003).save!
        assert_difference 'Account.all.length', -1 do
            Account.destroy_marked_accounts
        end
    end

    test "check if component is active" do
       assert accounts(:accounts_001).component_enabled?(account_components(:one).id)
       assert_equal false, accounts(:accounts_002).component_enabled?(account_components(:one).id)
    end

    test "should suspend account" do
        accounts(:accounts_001).suspend_account
        assert_equal true, accounts(:accounts_001).account_suspended?
    end

    test "common_project should return a project instance" do
      account = accounts(:accounts_001)
      assert_kind_of Project, account.common_project
    end

    test "common_project should return the correct project" do
      account = accounts(:accounts_001)
      project = account.common_project
      assert_equal 8, project.id
    end
        
protected

    def valid_new_params
         { :users_attributes => { "0" => { :firstname => 'Joe', :lastname => 'Bloggs', :email => 'info@bloggs.com', :password => 'password', :password_confirmation => 'password' }}, :site_address => 'new' }
    end
    
end

