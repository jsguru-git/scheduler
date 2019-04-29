require 'test_helper'

class AccountPlanTest < ActiveSupport::TestCase

    # validate presence
    test "validates presence of name" do
        account_plans(:account_plans_001).name = nil
        assert_equal account_plans(:account_plans_001).valid?, false
    end

    test "validates presence of price_in_cents" do
        account_plans(:account_plans_001).price_in_cents = nil
        assert_equal account_plans(:account_plans_001).valid?, false
    end

    test "validates presence of chargify_product_handle" do
        account_plans(:account_plans_001).chargify_product_handle = nil
        assert_equal account_plans(:account_plans_001).valid?, false
    end

    test "validates presence of chargify_product_number" do
        account_plans(:account_plans_001).chargify_product_number = nil
        assert_equal account_plans(:account_plans_001).valid?, false
    end

    # validate uniqueness
    test "validates uniqnuess of chargify_product_handle" do
        account_plans(:account_plans_001).chargify_product_handle = "test"
        account_plans(:account_plans_001).save
        account_plans(:account_plans_002).chargify_product_handle = "test"
        account_plans(:account_plans_002).save
        assert_equal false, account_plans(:account_plans_002).valid?
    end

    # validate numericality
    test "validates numericality of price_in_cents" do
        account_plans(:account_plans_001).price_in_cents = 1
        assert_equal account_plans(:account_plans_001).valid?, true

        account_plans(:account_plans_001).price_in_cents = "one"
        assert_equal account_plans(:account_plans_001).valid?, false
    end

    # expensive_first
    test "orders by expensive first" do
        assert_equal AccountPlan.order('account_plans.price_in_cents DESC').first, AccountPlan.expensive_first.first
    end

    # viewable
    test "does not show plans which are not viewable" do
        hidden_plan = account_plans(:account_plans_004)    
        assert_equal AccountPlan.viewable.include?(hidden_plan), false
    end

    # get_limit_model_types
    test "return fields imposing limits on account plan" do
       assert_equal AccountPlan.get_limit_model_types, ["user"]
    end

    # free_plan?
    test "plan is free or not" do
       assert_equal account_plans(:account_plans_001).free_plan?, true
       assert_equal account_plans(:account_plans_002).free_plan?, false
    end

    # price
    test "returns price in main currency denominator" do
        price = account_plans(:account_plans_002).price_in_cents / 100
        assert_equal account_plans(:account_plans_002).price, price
    end    
end

