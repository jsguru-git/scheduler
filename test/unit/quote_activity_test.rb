require 'test_helper'

class QuoteActivityTest < ActiveSupport::TestCase
  
  
  test "should create new activity" do
    assert_difference 'QuoteActivity.count', +1 do
      quote_activity = quotes(:quotes_002).quote_activities.new(:discount_percentage => 0.00, :estimate_type => 1, :name => 'test', :rate_card_id => rate_cards(:rate_cards_001).id, :estimate_scale => 1, :min_estimated => 60, :max_estimated => 120)
      assert quote_activity.save!
    end
  end
  
  
  test "should create new activity with 50% discount" do
    assert_difference 'QuoteActivity.count', +1 do
      quote_activity = quotes(:quotes_002).quote_activities.new(:discount_percentage => 50.00, :estimate_type => 1, :name => 'test', :rate_card_id => rate_cards(:rate_cards_001).id, :estimate_scale => 1, :min_estimated => 60, :max_estimated => 120)
      assert quote_activity.save!
      assert_equal 2400000, quote_activity.min_amount_cents
      assert_equal 4800000, quote_activity.max_amount_cents
    end
  end
  
  
  test "should check rate card must belong to the same account as the quote" do
    quote_activity = quotes(:quotes_002).quote_activities.new(:discount_percentage => 0.00, :estimate_type => 1, :name => 'test', :rate_card_id => rate_cards(:rate_cards_006).id, :estimate_scale => 1, :min_estimated => 60, :max_estimated => 120)
    assert_equal false, quote_activity.save
    assert quote_activity.errors[:rate_card_id].present?
  end
  
  
  test "should calcualte cost based on rate card and time entered" do
    quote_activity = quotes(:quotes_002).quote_activities.new(:discount_percentage => 0.00, :estimate_type => 1, :name => 'test', :rate_card_id => rate_cards(:rate_cards_001).id, :estimate_scale => 1, :min_estimated => 60, :max_estimated => 120)
    assert quote_activity.save!
    
    assert_equal 4800000, quote_activity.min_amount_cents
    assert_equal 9600000, quote_activity.max_amount_cents
  end
  
  
  test "should check that min estiamte is always less than max" do
    quote_activity = quotes(:quotes_002).quote_activities.new(:discount_percentage => 0.00, :estimate_type => 1, :name => 'test', :rate_card_id => rate_cards(:rate_cards_001).id, :estimate_scale => 1)

    quote_activity.attributes = {:min_estimated => 60, :max_estimated => 120}
    assert quote_activity.save!

    quote_activity.attributes = {:min_estimated => 69, :max_estimated => 59}
    assert_equal false, quote_activity.save

    assert quote_activity.errors[:min_estimated_minutes].present?
  end


  test "should convert days into mins on save" do
    quote_activity = quotes(:quotes_002).quote_activities.new(:discount_percentage => 0.00, :estimate_type => 1, :name => 'test', :rate_card_id => rate_cards(:rate_cards_001).id)
    quote_activity.min_estimated = 1
    quote_activity.max_estimated = 2
    quote_activity.estimate_scale = 1

    quote_activity.save

    # Saved
    assert_equal 480, quote_activity.min_estimated_minutes
    assert_equal 960, quote_activity.max_estimated_minutes
    
    # Output
    assert_equal 1, quote_activity.min_estimated_out
    assert_equal 2, quote_activity.max_estimated_out
  end


  test "should convert weeks into mins on save" do
    quote_activity = quotes(:quotes_002).quote_activities.new(:discount_percentage => 0.00, :estimate_type => 1, :name => 'test', :rate_card_id => rate_cards(:rate_cards_001).id)
    quote_activity.min_estimated = 1
    quote_activity.max_estimated = 2
    quote_activity.estimate_scale = 2

    quote_activity.save

    # Saved
    assert_equal 2400, quote_activity.min_estimated_minutes
    assert_equal 4800, quote_activity.max_estimated_minutes
    
    # Output
    assert_equal 1, quote_activity.min_estimated_out
    assert_equal 2, quote_activity.max_estimated_out
  end


  test "should convert months into mins on save" do
    quote_activity = quotes(:quotes_002).quote_activities.new(:discount_percentage => 0.00, :estimate_type => 1, :name => 'test', :rate_card_id => rate_cards(:rate_cards_001).id)
    quote_activity.min_estimated = 1
    quote_activity.max_estimated = 2
    quote_activity.estimate_scale = 3

    quote_activity.save

    # Saved
    assert_equal 10260, quote_activity.min_estimated_minutes
    assert_equal 20520, quote_activity.max_estimated_minutes
    
    # Output
    assert_equal 1, quote_activity.min_estimated_out
    assert_equal 2, quote_activity.max_estimated_out
  end
  
  
  test "should set min fields to 0 if its an exact quote" do
    quote_activities(:quote_activities_005).estimate_type = 0
    quote_activities(:quote_activities_005).save!
    
    assert_equal quote_activities(:quote_activities_005).max_estimated_minutes, quote_activities(:quote_activities_005).min_estimated_minutes
    assert_equal quote_activities(:quote_activities_005).max_estimated, quote_activities(:quote_activities_005).min_estimated
  end
  
  
  test "should get the min cost in the report currency" do
    assert_equal 124954, quote_activities(:quote_activities_004).min_amount_cents_in_report_currency
  end
  
  
  test "should get the max cost in the report currency" do
    assert_equal 249909, quote_activities(:quote_activities_004).max_amount_cents_in_report_currency
  end

  test '#to_task_attributes should give hash of track attribute' do
    quote = quote_activities(:quote_activities_005)
    attributes = quote.to_task_attributes

    assert_equal quote.name, attributes[:name]
    assert_equal quote.id, attributes[:quote_activity_id]
    assert_equal true, attributes[:count_towards_time_worked]
  end
  
end
