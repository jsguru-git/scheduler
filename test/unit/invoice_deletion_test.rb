require 'test_helper'

class InvoiceDeletionTest < ActiveSupport::TestCase
  
  
  test "should check relationships with user, project and account" do
    assert_not_nil invoice_deletions(:invoice_deletions_001).user
    assert_not_nil invoice_deletions(:invoice_deletions_001).project
    assert_not_nil invoice_deletions(:invoice_deletions_001).account
  end
  
  
  test "should create entry" do
    assert_difference 'InvoiceDeletion.all.length', +1 do
      invocie_deletion = InvoiceDeletion.new(valid_params)
      invocie_deletion.account_id = accounts(:accounts_001).id
      invocie_deletion.save!
    end
  end
  
  
  test "should create entry but fail as user belongs to different account" do
    invocie_deletion = InvoiceDeletion.new(valid_params.merge!(:user_id => users(:users_002).id))
    invocie_deletion.account_id = accounts(:accounts_001).id
    assert_equal false, invocie_deletion.save
    assert invocie_deletion.errors[:user_id].present?
  end
  
  
  test "should create entry but fial as project belongs to different account" do
    invocie_deletion = InvoiceDeletion.new(valid_params.merge!(:project_id => projects(:projects_007).id))
    invocie_deletion.account_id = accounts(:accounts_001).id
    assert_equal false, invocie_deletion.save
    assert invocie_deletion.errors[:project_id].present?
  end
  
  
  test "should delete and invoice and create deletion entry" do
    assert_difference 'InvoiceDeletion.all.length', +1 do
      assert_difference 'Invoice.all.length', -1 do
        InvoiceDeletion.destroy_invoice(invoices(:invoices_001), users(:users_001))
      end
    end
  end
  

protected


  def valid_params
    {:project_id => projects(:projects_001).id, 
    :user_id => users(:users_001).id, 
    :default_currency_total_amount_cents_exc_vat => 100, 
    :invoice_number => "6", 
    :invoice_date => Time.now.to_date}
  end
  

end
