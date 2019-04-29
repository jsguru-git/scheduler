require 'test_helper'

class CurrencyTest < ActiveSupport::TestCase


  test "should update currencies with ones which already exist" do
    assert_no_difference 'Currency.all.length' do
      Currency.update_rates_in_db({"AED" => 2.672725, "ANG" => 1})
    end
    
    aed = Currency.find_by_iso_code('AED')
    assert_equal 2.672725, aed.exchange_rate
    
    ang = Currency.find_by_iso_code('ANG')
    assert_equal 1, ang.exchange_rate
  end
  
  
  test "should update currencies with ones which dont already exist" do
    assert_difference 'Currency.all.length', +2 do
      Currency.update_rates_in_db({"AEDF" => 2.672725, "ANGD" => 1, "ANG" => 1.4})
    end
    
    aed = Currency.find_by_iso_code('AEDF')
    assert_equal 2.672725, aed.exchange_rate
    
    ang = Currency.find_by_iso_code('ANGD')
    assert_equal 1, ang.exchange_rate
  end
  
  
  test "should get exchange rate for different currencies" do
    assert_equal "1.162822226942733054788".to_d, Currency.get_exchange_for('GBP', 'EUR')
    assert_equal 1.5619337989978632, Currency.get_exchange_for('GBP', 'USD')
    assert_equal 0.640232, Currency.get_exchange_for('USD', 'GBP')
    assert_equal 1, Currency.get_exchange_for('USD', 'USD')
    assert_equal 1, Currency.get_exchange_for('GBP', 'GBP')
  end
  
  
  test "should get exchange rate for a currency that doesnt exist in the database" do
    assert_equal 0, Currency.get_exchange_for('USB', 'GBP')
  end
  
  
  test "should convert amount from one currency to another" do
    amount_cents = Currency.convert_amount('gbp', 'gbp', 10000)
    assert_equal 10000, amount_cents
    
    amount_cents = Currency.convert_amount('gbp', 'USD', 10000)
    assert_equal 15619, amount_cents
  end


end