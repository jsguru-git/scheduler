require 'test_helper'

class InoviceItemTrack < ActiveModel::TestCase
  
  # Test complience with ActiveModel
  include ActiveModel::Lint::Tests

  
  def setup
    @model = AutoPaymentProfile.new
  end
  
  
  test "should generate invoice items from tracked data" do
    invoice_item_track = InvoiceItemTrack.new(:start_date => '2012-07-01', :end_date => '2012-07-15', :currency => 'gbp', :payment_profile_id => payment_profiles(:payment_profiles_004).id)
    invoice_item_track.project_id = payment_profiles(:payment_profiles_004).project_id
    assert invoice_item_track.valid?
    
    invoice_items = invoice_item_track.generate_invoice_items
    
    assert_not_nil invoice_items
    assert_equal payment_profiles(:payment_profiles_004).name, invoice_items.name
    assert_equal 250.0, invoice_items.amount
  end
  
  
  test "should set defaults" do
    invoice_item_track = InvoiceItemTrack.new
    invoice_item_track.set_defaults
    
    assert_equal Date.today - 2.weeks, invoice_item_track.start_date
    assert_equal Date.today, invoice_item_track.end_date
  end
  
  
  test "should check if data exists for the given date range on validation" do
    invoice_item_track = InvoiceItemTrack.new(:start_date => '2013-07-01', :end_date => '2013-07-15', :currency => 'gbp', :payment_profile_id => payment_profiles(:payment_profiles_001).id)
    invoice_item_track.project_id = payment_profiles(:payment_profiles_001).project_id
    
    assert_equal false, invoice_item_track.valid?
    assert invoice_item_track.errors[:base].present?
  end
  
  
  test "should check that the provided dates are valid" do
    invoice_item_track = InvoiceItemTrack.new(:start_date => '2013-07-01', :end_date => '2012-07-15', :currency => 'gbp', :payment_profile_id => payment_profiles(:payment_profiles_001).id)
    invoice_item_track.project_id = payment_profiles(:payment_profiles_001).project_id
    
    assert_equal false, invoice_item_track.valid?
    assert invoice_item_track.errors[:end_date].present?
  end
  
  
  test "should check that the payment profile chosen belongs to the project which is set" do
    invoice_item_track = InvoiceItemTrack.new(:start_date => '2012-07-01', :end_date => '2012-07-15', :currency => 'gbp', :payment_profile_id => payment_profiles(:payment_profiles_001).id)
    invoice_item_track.project_id = projects(:projects_001).id
    
    assert_equal false, invoice_item_track.valid?
    assert invoice_item_track.errors[:base].present?
  end
  
  
end