require 'test_helper'

class InvoiceUsageTest < ActiveSupport::TestCase
  
  
  test "should create a invoice usage" do
    invoice_usage = invoices(:invoices_002).invoice_usages.new(:name => 'test', :amount => 1.11)
    invoice_usage.user_id = users(:users_001).id
    assert invoice_usage.save!
    
    assert_not_nil invoice_usage.allocated_at
  end
  
  
  test "should create invoice usage but fail as user and invoice belong to different account" do
    invoice_usage = invoices(:invoices_002).invoice_usages.new(:name => 'test', :amount => 1.11)
    invoice_usage.user_id = users(:users_002).id
    assert_equal false, invoice_usage.save
    assert invoice_usage.errors[:user_id].present?
  end
  
  
  test "should create invoice usage but fail due to total usage amount exceeding invoice amount" do
    invoice_usage = invoices(:invoices_002).invoice_usages.new(:name => 'test', :amount => '640.00')
    invoice_usage.user_id = users(:users_001).id
    invoice_usage.save
    assert invoice_usage.errors[:amount].present?
    
    invoice_usages(:one).amount = '640.00'
    assert invoice_usages(:one).save
    assert_equal false, invoice_usages(:one).errors[:amount].present?
    
    invoice_usages(:one).amount = '640.01'
    invoice_usages(:one).save
    assert invoice_usages(:one).errors[:amount].present?
  end
  
  
  test "should get amount in doller equivalent" do
    assert_equal 1.50, invoice_usages(:one).amount
  end
  
  
  test "should set the amount cents from doller equivalent" do
    invoice_usages(:one).amount = 2.00
    invoice_usages(:one).save!
    assert_equal 200, invoice_usages(:one).amount_cents
  end
  
  
  test "should get the outstanding amount left for an invoice" do
    assert_equal 63850, InvoiceUsage.amount_remaining_for(invoices(:invoices_002))
  end
  
  
  test "should get the amount cents allocated betweem a given period" do
    start_date = Time.new(2013,6,1).to_date
    end_date = start_date + 30.days
    amount = InvoiceUsage.amount_cents_allocated_for_period(accounts(:accounts_001), start_date, end_date)
    assert_equal 150, amount
  end
  
  
  test "should get all the allocations betweem a given period" do
    start_date = Time.new(2013,6,1).to_date
    end_date = start_date + 30.days
    usages = InvoiceUsage.allocated_for_period_and_account(accounts(:accounts_001), start_date, end_date)
    assert_not_nil usages
  end
  
  
end
