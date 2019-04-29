require 'test_helper'

class QuoteTest < ActiveSupport::TestCase
  
  
  test "should create a new quote with defaults" do
    quote = projects(:projects_001).quotes.new
    quote.set_defaults
    quote.user_id = users(:users_001).id
    
    assert_difference 'Quote.all.length', +1 do
      quote.save!
    end
    assert quote.new_quote?
    assert_equal accounts(:accounts_001).account_setting.default_currency, quote.currency
  end
  
  
  test "should check that new quote is set to draft" do
    quote = projects(:projects_001).quotes.new
    quote.set_defaults
    quote.user_id = users(:users_001).id
    quote.save!
    
    assert quote.draft?
  end
  
  
  test "should check that a draft quote gets cheanged to live when updated" do
    quotes(:quotes_004).title = 'my new title'
    quotes(:quotes_004).save!
    
    assert_equal false, quotes(:quotes_004).draft?
  end
  
  
  test "can not create a version of an instance that is already a version" do
    quote = projects(:projects_001).quotes.new
    quote.set_defaults
    quote.user_id = users(:users_001).id
    quote.attributes = {:quote_id => quotes(:quotes_002).id, :new_quote => false}
    
    assert_no_difference 'Quote.all.length' do
      quote.save
    end
    
    assert quote.errors[:quote_id].present?
  end
  
  
  test "should check version relationships" do
    assert_nil quotes(:quotes_001).parent_quote
    assert_equal 1, quotes(:quotes_001).version_quotes.length
    
    assert_equal quotes(:quotes_001).id, quotes(:quotes_002).parent_quote.id
    assert_equal 0, quotes(:quotes_002).version_quotes.length
  end
  
  
  test "should extract all version 1 quotes" do
    quotes = Quote.v1_quotes
    quotes.each do |quote|
      assert quote.new_quote?
    end
  end
  
  
  test "should set title to nil when not a new quote" do
    quotes(:quotes_003).attributes = {:quote_id => quotes(:quotes_001).id, :new_quote => false}
    quotes(:quotes_003).save!
    
    assert_nil quotes(:quotes_003).title
  end
  
  
  test "should set quote_id to nil when it is a new quote" do
    quotes(:quotes_002).attributes = {:new_quote => true}
    quotes(:quotes_002).save!
    
    assert_nil quotes(:quotes_003).quote_id
  end
  
  
  test "should make sure vat rate is a valid number" do
    quotes(:quotes_002).attributes = {:vat_rate => -1}
    assert_equal false, quotes(:quotes_002).save
  end
  
  
  test "should not be able to create a new quote where the parent belongs to a different project" do
    quote = projects(:projects_002).quotes.new
    quote.set_defaults
    quote.user_id = users(:users_001).id
    quote.attributes = {:quote_id => quotes(:quotes_001).id, :new_quote => false}
    assert_equal false, quote.save
    assert quote.errors[:quote_id].present?
  end
  
  
  test "should check chosen currency is supported on save" do
    quotes(:quotes_002).attributes = {:currency => 'dfd'}
    assert_equal false, quotes(:quotes_002).save
    assert quotes(:quotes_002).errors[:currency].present?
  end
  
  
  test "should get a quote title for a v1 quote" do
    assert_equal 'My quote', quotes(:quotes_001).display_title
  end
  
  
  test "should get a quote title for a v2 quote" do
    assert_equal 'My quote - v2.0', quotes(:quotes_002).display_title
  end
  
  
  test "should get a quote title for a v1 quote with no title" do
    quotes(:quotes_001).title = ''
    quotes(:quotes_001).save!
    assert_equal 'No title', quotes(:quotes_001).display_title
  end
  
  
  test "should get version number for a v1 quote" do
    assert_equal '1.0', quotes(:quotes_001).version_number
  end
  
  
  test "should get version number for a v2 quote" do
    assert_equal '2.0', quotes(:quotes_002).version_number
  end
  
  
  test "should get previous quote where one exists" do
    quote = quotes(:quotes_002).get_previous_quote_version
    assert_equal quotes(:quotes_001).id, quote.id
  end
  
  
  test "should get previous quote where one doesnt exist" do
    quote = quotes(:quotes_001).get_previous_quote_version
    assert_nil quote
  end
  
  
  test "should get original quote when viewing original" do
    quote = quotes(:quotes_001).get_origional_quote
    assert_equal quotes(:quotes_001).id, quote.id
  end
  
  
  test "should get original quote when viewing v2" do
    quote = quotes(:quotes_002).get_origional_quote
    assert_equal quotes(:quotes_001).id, quote.id
  end
  
  
  test "should get min cost excluding vat and discount" do
    assert_equal 240000, quotes(:quotes_002).total_min_cost_ex_discount_and_vat_cents
  end
  
  
  test "should get max cost excluding vat and discount" do
    assert_equal 400000, quotes(:quotes_002).total_max_cost_ex_discount_and_vat_cents
  end
  
  
  test "should get min cost including vat and discount" do
    assert_equal 259200, quotes(:quotes_002).total_min_cost_incl_discount_and_vat_cents
  end
  
  
  test "should get max cost including vat and discount" do
    assert_equal 432000, quotes(:quotes_002).total_max_cost_incl_discount_and_vat_cents
  end
  
  
  test "should get min cost excluding vat and discount when there is an extra cost" do
    quotes(:quotes_002).extra_cost_cents = 100
    quotes(:quotes_002).extra_cost_title = 'Travel'
    quotes(:quotes_002).save!
    
    assert_equal 240100, quotes(:quotes_002).total_min_cost_ex_discount_and_vat_cents
  end
  
  
  test "should get max cost excluding vat and discount when there is an extra cost" do
    quotes(:quotes_002).extra_cost_cents = 100
    quotes(:quotes_002).extra_cost_title = 'Travel'
    quotes(:quotes_002).save!
    
    assert_equal 400100, quotes(:quotes_002).total_max_cost_ex_discount_and_vat_cents
  end
  
  
  test "should get min cost excl vat and discount in report currency" do
    assert_equal 374862, quotes(:quotes_002).total_min_cost_excl_discount_and_vat_cents_in_report_currency
  end
  
  
  test "should get max cost excl vat and discount in report currency" do
    assert_equal 624772, quotes(:quotes_002).total_max_cost_excl_discount_and_vat_cents_in_report_currency
  end
  
  
  test "should get min cost incl vat and discount in report currency" do
    assert_equal 404858, quotes(:quotes_002).total_min_cost_incl_discount_and_vat_cents_in_report_currency
  end
  
  
  test "should get max cost incl vat and discount in report currency" do
    assert_equal 674762, quotes(:quotes_002).total_max_cost_incl_discount_and_vat_cents_in_report_currency
  end

  
  test "should get min cost excl vat and discount in report currency when there is an extra cost" do
    quotes(:quotes_002).extra_cost_cents = 100
    quotes(:quotes_002).extra_cost_title = 'Travel'
    quotes(:quotes_002).save!
    
    assert_equal 375018, quotes(:quotes_002).total_min_cost_excl_discount_and_vat_cents_in_report_currency
  end
  
  
  test "should get max cost excl vat and discount in report currency when there is an extra cost" do
    quotes(:quotes_002).extra_cost_cents = 100
    quotes(:quotes_002).extra_cost_title = 'Travel'
    quotes(:quotes_002).save!
    
    assert_equal 624928, quotes(:quotes_002).total_max_cost_excl_discount_and_vat_cents_in_report_currency
  end
  
  
  test "should get report currency exchange rate" do
    assert_equal 1, quotes(:quotes_001).report_currency_exchange_rate
    
    assert_equal 1.5619337989978632, quotes(:quotes_002).report_currency_exchange_rate
  end
  
  
  test "should search quotes by client" do
    quotes = Quote.search(accounts(:accounts_001), {})
    assert_not_nil quotes
  end
  
  
  test "should copy all activities from a previous quote" do
    copied = quotes(:quotes_002).copy_activities_from_previous_quote
    assert_equal 2, copied
    quotes(:quotes_002).reload
    assert_equal 2, quotes(:quotes_002).quote_activities.length
  end
  
  
  test "should create deafult secitons" do
    quote = projects(:projects_001).quotes.new
    quote.set_defaults
    quote.user_id = users(:users_001).id
    quote.save!
    
    assert_difference 'QuoteSection.all.length', +3 do
      quote.create_default_sections!
    end
  end
  
  
  test "should make sure the latest version that is in progress is the only editable type" do
    assert_equal false, quotes(:quotes_001).editable?
    assert_equal true, quotes(:quotes_002).editable?
    
    quotes(:quotes_002).quote_status = 1
    quotes(:quotes_002).save!
    assert_equal false, quotes(:quotes_002).editable?
  end
  
  
  test "should check if quote is the latest version" do
    assert_equal false, quotes(:quotes_001).is_latest_version?
    assert quotes(:quotes_002).is_latest_version?
  end
  
  
  test "should output vat and remove trailing decimal places" do
    assert_equal 20.0, quotes(:quotes_001).vat_rate
    assert_equal '20', quotes(:quotes_001).vat_rate_out
  end
  
  
  test "should output discount and remove trailing decimal places" do
    assert_equal 10.0, quotes(:quotes_002).discount_percentage
    assert_equal '10', quotes(:quotes_002).discount_percentage_out
  end
  
  
  test "should set the last saved by user" do
    quotes(:quotes_002).update_last_saved_by_to(users(:users_001))
    assert_equal quotes(:quotes_002).last_saved_by_id, users(:users_001).id
  end


  test "should get the updated time for the exchange rate in use" do
    assert_equal Time.parse('2013-02-12 11:37:32'), quotes(:quotes_002).get_exchange_rate_updated_at
    
    quotes(:quotes_002).quote_status = 1
    quotes(:quotes_002).save!
    
    assert_equal Time.parse('2013-02-12 11:37:32'), quotes(:quotes_002).get_exchange_rate_updated_at
  end
  
  
  test "should cache exchange rate when changing a project from in progress to any other status" do
    quotes(:quotes_002).quote_status = 1
    quotes(:quotes_002).save!
    
    assert_not_nil quotes(:quotes_002).exchange_rate
    assert_not_nil quotes(:quotes_002).exchange_rate_updated_at
  end
  
  
  test "should set exchange rate to nil when changing a project back in progress" do
    quotes(:quotes_002).quote_status = 1
    quotes(:quotes_002).save!
    
    quotes(:quotes_002).quote_status = 0
    quotes(:quotes_002).save!
    
    assert_nil quotes(:quotes_002).exchange_rate
    assert_nil quotes(:quotes_002).exchange_rate_updated_at
  end
  
  
  test "should check if estiamte has a range estimate included" do
    assert quotes(:quotes_002).include_range_estimates?
  end
  
  
  test "should get extra costs" do
    quotes(:quotes_002).extra_cost_cents = 100
    assert_equal 1.00, quotes(:quotes_002).extra_cost
  end
  
  
  test "should set extra costs" do
    quotes(:quotes_002).extra_cost = 1
    assert_equal 100, quotes(:quotes_002).extra_cost_cents
  end
  
  
  test "should get extra cost in report currency" do
    quotes(:quotes_002).extra_cost_cents = 100
    quotes(:quotes_002).extra_cost_title = 'Travel'
    quotes(:quotes_002).save!
    
    assert_equal 156, quotes(:quotes_002).extra_cost_cents_in_report_currency
  end
  
  
  test "should delete old draft qutoes" do
    quote = projects(:projects_001).quotes.new
    quote.set_defaults
    quote.user_id = users(:users_001).id
    quote.save!
    
    assert_difference 'Quote.all.length', -1 do
      # New one shouldnt be delete and existing one in fixutures should
      Quote.delete_old_draft_quotes
    end
    
    quote.reload
    assert_not_nil quote
  end
  
  
end
