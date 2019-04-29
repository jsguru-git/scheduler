require 'test_helper'

class InvoiceItemTest < ActiveSupport::TestCase
  
  
  test "should set amount_cents from amount" do
    invoice_items(:invoice_items_001).amount = 200.50
    invoice_items(:invoice_items_001).save!
    assert_equal 20050, invoice_items(:invoice_items_001).amount_cents
  end
  
  
  test "should get amount from cents" do
    assert_equal 540.00, invoice_items(:invoice_items_001).amount
  end
  
  
  test "should generate invoice item from payment stage" do
    invoice_items = InvoiceItem.generate_from_payment_profile(projects(:projects_002), {:currency => 'gbp', :payment_profiles => [payment_profiles(:payment_profiles_001).id]})
    assert_not_nil invoice_items
    assert_equal payment_profiles(:payment_profiles_001).expected_cost_cents, invoice_items.first.amount_cents
  end
  
  
  test "should get amount cents for quantity of two" do
    invoice_items(:invoice_items_001).amount = 200.50
    invoice_items(:invoice_items_001).quantity = 2
    invoice_items(:invoice_items_001).save!
    assert_equal 40100, invoice_items(:invoice_items_001).amount_cents_incl_quantity
  end
  
  
end
