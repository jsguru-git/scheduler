require 'test_helper'

class PaymentProfileTest < ActiveSupport::TestCase


  test "should create a payment profile with manual cost entered" do
    payment_profile = projects(:projects_002).payment_profiles.new
    payment_profile.attributes = {:name => 'payment stage', :expected_cost => 44.55, :expected_payment_date => Date.today}

    assert_difference 'PaymentProfile.all.length', +1 do
      payment_profile.save
    end
  end


  test "should create a payment profile with cost automatically calculated from time" do
    payment_profile = projects(:projects_001).payment_profiles.new
    payment_profile.attributes = {:name => 'payment stage', :expected_days => 1, :expected_payment_date => Date.today, :generate_cost_from_time => true}

    assert_difference 'PaymentProfile.all.length', +1 do
      payment_profile.save!
      payment_profile.rate_card_payment_profiles.new(:percentage => 90, :rate_card_id => rate_cards(:rate_cards_002).id)
      payment_profile.save!
    end
    assert_equal 180000, payment_profile.expected_cost_cents
  end


  test "should update a payment profile with manual cost entered" do
    payment_profiles(:payment_profiles_001).update_attributes(:expected_cost => 20)
    payment_profiles(:payment_profiles_001).reload

    assert_equal 2000, payment_profiles(:payment_profiles_001).expected_cost_cents
  end


  test "should update a payment profile with cost automatically calculated from time" do
    payment_profiles(:payment_profiles_003).update_attributes(:expected_days => 20)
    payment_profiles(:payment_profiles_003).reload

    assert_equal 4000000, payment_profiles(:payment_profiles_003).expected_cost_cents
  end


  test "test should check expected days can only be down to 2 decimal places" do
    payment_profile = projects(:projects_001).payment_profiles.new
    payment_profile.attributes = {:name => 'payment stage', :expected_days => 1.25, :expected_payment_date => Date.today, :generate_cost_from_time => true}

    assert payment_profile.valid?

    payment_profile.expected_days =1.255
    assert_equal false, payment_profile.valid?
  end


  test "should check associated rate cards belong to same account" do
    payment_profile = projects(:projects_001).payment_profiles.new
    payment_profile.attributes = {:name => 'payment stage', :expected_days => 1, :expected_payment_date => Date.today, :generate_cost_from_time => true}

    payment_profile.save!
    payment_profile.rate_card_payment_profiles.new(:percentage => 90, :rate_card_id => rate_cards(:rate_cards_002).id)

    assert payment_profile.valid?

    payment_profile.rate_card_payment_profiles.first.rate_card_id = rate_cards(:rate_cards_006).id
    assert_equal false, payment_profile.valid?
  end


  test "should check associated rate cards can only be included once" do
    payment_profile = projects(:projects_001).payment_profiles.new
    payment_profile.attributes = {:name => 'payment stage', :expected_days => 1, :expected_payment_date => Date.today, :generate_cost_from_time => true}

    payment_profile.save!

    payment_profile.rate_card_payment_profiles.new(:percentage => 90, :rate_card_id => rate_cards(:rate_cards_002).id)
    payment_profile.rate_card_payment_profiles.new(:percentage => 90, :rate_card_id => rate_cards(:rate_cards_002).id)

    assert_equal false, payment_profile.valid?
  end


  test "should not allow profile to be removed if it has a invoice attached" do
    invoice_item = InvoiceItem.new(:quantity => 1, :vat => true, :name => 'test', :amount => 100)
    invoice_item.payment_profile_id = payment_profiles(:payment_profiles_001).id
    invoice_item.invoice_id = 1
    invoice_item.save(:validate => false)

    payment_profiles(:payment_profiles_001).save

    assert_no_difference 'PaymentProfile.all.length' do
      payment_profiles(:payment_profiles_001).destroy
    end
  end


  test "should output cost in readable string with currency symbol" do
    assert_equal '$300', payment_profiles(:payment_profiles_001).expected_cost_formatted
  end


  test "should get the % service types assigned to payment profile" do
    assert_equal 0, payment_profiles(:payment_profiles_001).service_type_percentage
    assert_equal 100, payment_profiles(:payment_profiles_003).service_type_percentage
  end


  test "should get expected cost in dollers or currency equivalent" do
    assert_equal 300, payment_profiles(:payment_profiles_001).expected_cost
  end


  test "should set expected_cost_cents from dollers or currency equivalent" do
    payment_profiles(:payment_profiles_001).expected_cost = 400
    payment_profiles(:payment_profiles_001).save

    assert_equal 400, payment_profiles(:payment_profiles_001).expected_cost
  end


  test "should get expected days" do
    assert_equal 1.0, payment_profiles(:payment_profiles_003).expected_days
  end


  test "should set expected mins from expected days" do
    payment_profiles(:payment_profiles_003).expected_days = 5.25
    payment_profiles(:payment_profiles_003).save

    assert_equal 2520.0, payment_profiles(:payment_profiles_003).expected_minutes
    assert_equal 5.25, payment_profiles(:payment_profiles_003).expected_days
  end
  
  
  test "should find payment profiles for a given project" do
    profiles = PaymentProfile.search_stages(projects(:projects_002), {})
    assert_not_nil profiles
  end
  
  
  test "should find payment profiles that are uninvoiced for a given project" do
    # All uninvoiced
    profiles = PaymentProfile.search_stages(projects(:projects_002), {:stages => 1})
    assert_not_nil profiles
    profiles.each do |profile|
      assert profile.invoice_item.blank?
    end
  end
  
  
  test "should find payment profiles that are invoiced for a given project" do
    # All invoiced
    profiles = PaymentProfile.search_stages(projects(:projects_002), {:stages => 2})
    assert_not_nil profiles
    profiles.each do |profile|
      assert profile.invoice_item.present?
    end
  end
  
  
  test "find all un-invoiced payment profiles for a given date range" do
    start_date = Time.new(2013,3,20).to_date
		end_date = start_date + 20.days
    payment_profiles = PaymentProfile.un_invoiced_expected_for_between_dates(start_date, end_date)
    
    assert_not_nil payment_profiles
    payment_profiles.each do |payment_profile|
      assert payment_profile.expected_payment_date >= start_date
      assert payment_profile.expected_payment_date <= end_date
    end
  end
  
  
  test "should require expected data change reason if its month or year has been changed" do
    payment_profiles(:payment_profiles_001).expected_payment_date = payment_profiles(:payment_profiles_001).expected_payment_date + 1.day
    assert payment_profiles(:payment_profiles_001).valid?
    
    payment_profiles(:payment_profiles_001).expected_payment_date = payment_profiles(:payment_profiles_001).expected_payment_date + 1.month
    assert_equal false, payment_profiles(:payment_profiles_001).valid?
    assert payment_profiles(:payment_profiles_001).errors[:reason_for_date_change].present?
  end
  
  
  test "should create payment profile rollover entry if month or year has been changed" do
    assert_no_difference 'PaymentProfileRollover.count' do
      payment_profiles(:payment_profiles_001).expected_payment_date = payment_profiles(:payment_profiles_001).expected_payment_date + 1.day
      payment_profiles(:payment_profiles_001).save
    end
    
    
    assert_difference 'PaymentProfileRollover.count', +1 do
      payment_profiles(:payment_profiles_001).expected_payment_date = payment_profiles(:payment_profiles_001).expected_payment_date + 1.month
      payment_profiles(:payment_profiles_001).reason_for_date_change = 'My reason'
      payment_profiles(:payment_profiles_001).save
    end
    
  end
  
  
end

