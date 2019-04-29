require 'test_helper'

class ClientRateCardTest < ActiveSupport::TestCase
    
    
    #
    #
    test "create a client rate card" do
        assert_difference 'ClientRateCard.all.length', +1 do
            client_rate_card = clients(:clients_001).client_rate_cards.new(:rate_card_id => rate_cards(:rate_cards_002).id, :daily_cost => '100')
            assert client_rate_card.save
        end
    end
    
    
    #
    #
    test "create a client rate card but fail as one already exists" do
        client_rate_card = clients(:clients_001).client_rate_cards.new(:rate_card_id => rate_cards(:rate_cards_001).id, :daily_cost => '100')
        assert_equal false, client_rate_card.save
    end
    
    
    
    #
    #
    test "create client reate card and fail due to rate_card_id and client_id not belonging to same account" do
        client_rate_card = clients(:clients_004).client_rate_cards.new(:rate_card_id => rate_cards(:rate_cards_002).id, :daily_cost => '100')
        assert_equal false, client_rate_card.save
        assert client_rate_card.errors[:client_id].present?
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
    
    
end
