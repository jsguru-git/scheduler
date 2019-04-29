require 'test_helper'

class RateCardTest < ActiveSupport::TestCase
    
    
    #
    #
    test "should crate new service type" do
        assert_difference 'RateCard.all.length', +1 do
            accounts(:accounts_001).rate_cards.create(:service_type => 'new service', :daily_cost => '400.00')
        end
    end
    
    
    #
    #
    test "should get the daily cost" do
        rate_card = rate_cards(:rate_cards_001)
        assert_equal 800, rate_card.daily_cost
    end
    
    
    #
    #
    test "should set the daily cost in cents when saving" do
        rate_card = rate_cards(:rate_cards_001)
        rate_card.daily_cost = 90.22
        assert_equal 9022, rate_card.daily_cost_cents
    end
    
    
    #
    #
    test "should get most relevent rate card for a service type when a custom rate one exists" do
      rate_card = rate_cards(:rate_cards_001).most_relevant_rate_card_for(clients(:clients_001))
      assert_equal ClientRateCard, rate_card.class
    end
    
    
    #
    #
    test "should get most relevent rate card for a service type when a custom rate one doesnt exists" do
      rate_card = rate_cards(:rate_cards_002).most_relevant_rate_card_for(clients(:clients_001))
      assert_equal RateCard, rate_card.class
    end
    
    
    #
    #
    test "should get the cost per minute for client when a custom rate card exists" do
      mins = rate_cards(:rate_cards_001).cost_per_min_for_client(clients(:clients_001).id, clients(:clients_001).account).to_f
      assert_equal 166.66666666666666, mins
    end
    
    #
    #
    test "should get the cost per minute for client when no custom rate card exists" do
      mins = rate_cards(:rate_cards_002).cost_per_min_for_client(clients(:clients_001).id, clients(:clients_001).account).to_f
      assert_equal 416.6666666666667, mins
    end
    
    
end
