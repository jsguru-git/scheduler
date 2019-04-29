require 'test_helper'

class InvoiceTest < ActiveSupport::TestCase

  
  test "should set the correct exchange rate" do
    invoice = valid_new_invoice
    assert invoice.save
    assert_not_nil invoice.exchange_rate
    assert_equal 1.0, invoice.exchange_rate
  end

  test 'pre_payment is invalid if pre_payment is not set' do
    invoice = valid_new_invoice
    invoice.pre_payment = nil
    assert !invoice.valid?
  end
  
  test "should set the correct exchange rate in usd" do
    invoice = Invoice.new(valid_params.merge!(:currency => 'usd'))
    invoice.project_id = projects(:projects_002).id
    invoice.user_id = users(:users_001).id
    invoice.save
    assert_not_nil invoice.exchange_rate
    assert_equal 1.5619337989978632, invoice.exchange_rate
  end
  
  test "should set cached amounts from invoice_items for chosen currency" do
    invoice = valid_new_invoice
    invoice.save!
    assert_equal 12000, invoice.total_amount_cents_inc_vat
    assert_equal 10000, invoice.total_amount_cents_exc_vat
  end
  
  
  test "should set cached default currency amounts for invoice" do
    invoice = Invoice.new(valid_params.merge!(:currency => 'usd'))
    invoice.project_id = projects(:projects_002).id
    invoice.user_id = users(:users_001).id
    invoice.save!
    
    assert_equal 12000, invoice.total_amount_cents_inc_vat
    assert_equal 10000, invoice.total_amount_cents_exc_vat
     
    assert_equal 7682, invoice.default_currency_total_amount_cents_inc_vat
    assert_equal 6402, invoice.default_currency_total_amount_cents_exc_vat
  end
  
  
  test "should set cached default currency amounts for invoice when non vat item is present" do
    params = valid_params.merge!(:currency => 'usd')
    params[:invoice_items_attributes] << {:payment_profile_id => nil, :name => 'item name', :quantity => 1, :vat => false, :amount => 100.00}
    
    invoice = Invoice.new(params)
    invoice.project_id = projects(:projects_002).id
    invoice.user_id = users(:users_001).id
    invoice.save!
    
    assert_equal 22000, invoice.total_amount_cents_inc_vat
    assert_equal 20000, invoice.total_amount_cents_exc_vat
     
    assert_equal 14084, invoice.default_currency_total_amount_cents_inc_vat
    assert_equal 12804, invoice.default_currency_total_amount_cents_exc_vat
  end
  
  
  test "should get the amount cents after quantity of 2 is applied to a line item" do
    params = valid_params.merge!(:currency => 'usd')
    params[:invoice_items_attributes] << {:payment_profile_id => nil, :name => 'item name', :quantity => 2, :vat => true, :amount => 100.00}
    
    invoice = Invoice.new(params)
    invoice.project_id = projects(:projects_002).id
    invoice.user_id = users(:users_001).id
    invoice.save!
    
    assert_equal 36000, invoice.total_amount_cents_inc_vat
    assert_equal 30000, invoice.total_amount_cents_exc_vat
    
    assert_equal 23047, invoice.default_currency_total_amount_cents_inc_vat
    assert_equal 19206, invoice.default_currency_total_amount_cents_exc_vat
  end
  
  
  test "should set cached default currency amounts for invoice_items when using usd" do
    invoice = Invoice.new(valid_params.merge!(:currency => 'usd'))
    invoice.project_id = projects(:projects_002).id
    invoice.user_id = users(:users_001).id
    invoice.save!
    
    invoice_item = invoice.invoice_items.first

    assert_equal 10000, invoice_item.amount_cents
    assert_equal 6402, invoice_item.default_currency_amount_cents
  end
  
  
  test "should set cached default currency amounts for invoice_items when using default currency" do
    invoice = Invoice.new(valid_params)
    invoice.project_id = projects(:projects_002).id
    invoice.user_id = users(:users_001).id
    invoice.save!
    
    invoice_item = invoice.invoice_items.first

    assert_equal 10000, invoice_item.amount_cents
    assert_equal invoice_item.amount_cents, invoice_item.default_currency_amount_cents
  end
  
  
  test "should get currency iso code for the given invoice" do
    invoice = valid_new_invoice
    assert_equal 'GBP', invoice.currency_code
    
    invoice = Invoice.new(valid_params.merge!(:currency => 'usd'))
    assert_equal 'USD', invoice.currency_code
  end

  
  test "should get currency symbol for the given invoice" do
    invoice = Invoice.new(valid_params.merge!(:currency => 'usd'))
    assert_equal '$', invoice.currency_symbol
  end
  
  
  test "should get total amount inc vat from amount cents" do
    invoice = valid_new_invoice
    invoice.save!
    
    assert_equal 120.00, invoice.total_amount_inc_vat
  end
  
  
  test "should get total amount excl vat from amount cents" do
    invoice = valid_new_invoice
    invoice.save!
    
    assert_equal 100.00, invoice.total_amount_exc_vat
  end
  
  
  test "should get vat amount" do
    invoice = valid_new_invoice
    invoice.save!
    
    assert_equal 20.00, invoice.vat_amount
  end
  
  
  test "should get vat amoutn cents" do
    invoice = valid_new_invoice
    invoice.save!
    
    assert_equal 2000, invoice.vat_amount_cents
  end
  
  
  test "should get total amount inc vat in readable string" do
    invoice = Invoice.new(valid_params.merge!(:currency => 'usd'))
    invoice.project_id = projects(:projects_002).id
    invoice.user_id = users(:users_001).id
    invoice.save!
    
    assert_equal '$120.00', invoice.total_amount_inc_vat_in_currency
  end
  
  
  test "should set defaults for new invoice" do
    invoice = Invoice.new
    invoice.project_id = projects(:projects_002).id
    invoice.user_id = users(:users_001).id
    invoice.set_defaults
    
    assert_equal 'Pay within 30 days', invoice.terms
    assert_equal Date.today, invoice.invoice_date
    assert_equal false, invoice.pre_payment
  end
  
  
  test "should check invoice number is unique for account on creation" do
    invoice = Invoice.new(valid_params.merge!(:currency => 'usd', :invoice_number => invoices(:invoices_001).invoice_number))
    invoice.project_id = projects(:projects_002).id
    invoice.user_id = users(:users_001).id
    assert_equal false, invoice.valid?
    assert invoice.errors[:invoice_number].present?
  end
  
  
  test "should check invoice number is unique for account on update" do
    invoice = valid_new_invoice
    invoice.save!
    
    invoice.invoice_number = invoices(:invoices_001).invoice_number
    assert_equal false, invoice.valid?
    assert invoice.errors[:invoice_number].present?
  end
  
  
  test "should validate at least one invoice item is requried on save" do
    invoice = Invoice.new(valid_params.merge!(:currency => 'usd', :invoice_items_attributes => []))
    invoice.project_id = projects(:projects_002).id
    invoice.user_id = users(:users_001).id
    assert_equal false, invoice.valid?
    assert invoice.errors[:base].present?
  end
  
  
  test "should check only supproted currencies with exchange rates are allowed" do
    invoice = Invoice.new(valid_params.merge!(:currency => 'SKK'))
    invoice.project_id = projects(:projects_002).id
    invoice.user_id = users(:users_001).id
    assert_equal false, invoice.valid?
    assert invoice.errors[:currency].present?
  end
  
  
  test "should check invoice and payment profiles belong to the same project" do
    invoice = Invoice.new(valid_params.merge!(:currency => 'usd'))
    invoice.project_id = projects(:projects_003).id
    assert_equal false, invoice.valid?
    assert invoice.errors[:base].present?
  end
  
  test "should check invoice and user belong to the same account" do
    invoice = Invoice.new(valid_params.merge!(:currency => 'usd'))
    invoice.project_id = projects(:projects_002).id
    invoice.user_id = users(:users_002).id
    
    assert_equal false, invoice.valid?
    assert invoice.errors[:user_id].present?
  end
  
  test "should check a payment profile can only be invoiced once" do
    invoice = valid_new_invoice
    invoice.save!
    
    invoice2 = valid_new_invoice
    assert_equal false, invoice2.valid?
    assert invoice2.errors[:base].present?
  end
  
  
  test "should send new invoice email when invoice is created" do
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      invoice = valid_new_invoice
      invoice.save!
    end
  end
  
  
  test "should should not send new invoice email when not configured to" do
    account_settings(:account_settings_001).invoice_alert_email = nil
    account_settings(:account_settings_001).save!
    
    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      invoice = valid_new_invoice
      invoice.save!
    end
  end
  
  
  test "should get next invoice number" do
    number = Invoice.find_next_available_number_for(accounts(:accounts_001))
    assert_equal 3, number
  end
  
  
  test "should get the amount cents invoiced to a client betweem a given period" do
    start_date = Time.new(2013,4,10).to_date
    end_date = start_date + 6.days
    amount = Invoice.amount_cents_invoiced_for_period_and_client(clients(:clients_001).id, start_date, end_date)
    assert_equal 64000, amount
  end
  
  
  test "should get the amount cents invoiced to a project betweem a given period" do
    start_date = Time.new(2013,4,10).to_date
    end_date = start_date + 6.days
    amount = Invoice.amount_cents_invoiced_for_period_and_project(projects(:projects_002).id, start_date, end_date)
    assert_equal 64000, amount
  end
  
  
  test "should get the amount cents invoiced between a given period" do
    start_date = Time.new(2013,4,10).to_date
    end_date = start_date + 6.days
    amount = Invoice.amount_cents_invoiced_for_period(accounts(:accounts_001), start_date, end_date)
    assert_equal 128000, amount
  end
  
  
  test "should get the amount cents invoiced as a pre payment between a given period" do
    start_date = Time.new(2013,4,10).to_date
    end_date = start_date + 6.days
    amount = Invoice.amount_cents_pre_payment_invoiced_for_period(accounts(:accounts_001), start_date, end_date)
    assert_equal 64000, amount
  end
  
  
  test "should search pre payment invoiecs" do
    start_date = Time.new(2013,4,10).to_date
    end_date = start_date + 30.days
    projects = Invoice.search_pre_payments(accounts(:accounts_001), start_date, end_date, {})
    
    assert_not_nil projects

    projects.each do |project|
      project.invoices.each do |invoice|
        assert invoice.pre_payment?
      end
    end
  end
  
  
protected


  # return an un-saved invoice
  def valid_new_invoice
    invoice = Invoice.new(valid_params)
    invoice.project_id = projects(:projects_002).id
    invoice.user_id = users(:users_001).id
    invoice
  end
  
  
  # Valid params for a new invoice
  def valid_params
    {:address => 'Queen St', :invoice_date => '2013-04-15', :due_on_date => '2013-05-15', :invoice_number => 876, :terms => '30 days', :po_number => '7654', :pre_payment => false, :currency => 'gbp', :vat_rate => 20, :invoice_items_attributes => [{:payment_profile_id => payment_profiles(:payment_profiles_002).id, :name => 'item name', :quantity => 1, :vat => true, :amount => 100.00}] }
  end
  
  
end
