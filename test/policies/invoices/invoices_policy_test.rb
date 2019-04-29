require 'test_helper'
require 'policies/policies_test'

class Invoice::InvoicesPolicyTest < PoliciesTest

  def setup
    change_host_to(:accounts_001)
    @controller = Invoice::InvoicesController.new
  end

  test '#index is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :index, { project_id: 1, id: 1 }
  end

  test '#index is viewable by administrators' do
    login_as_role :administrator
    assert_authorized :index, { project_id: 1, id: 1 }
  end

  test '#index is not viewable by leaders' do
    login_as_role :leader
    assert_not_authorized :index, { project_id: 1, id: 1 }
  end

  test '#index is not viewable by members' do
    login_as_role :member
    assert_not_authorized :index, { project_id: 1, id: 1}
  end

  test '#show is viewable by account_holders' do
    project = create(:project, account_id: 1)
    invoice = create(:invoice, invoice_items: build_list(:invoice_item, 1), project: project)
    login_as_role :account_holder
    assert_authorized :show, { project_id: project.id, id: invoice.id }
  end

  test '#show is viewable by administrators' do
    project = create(:project, account_id: 1)
    invoice = create(:invoice, invoice_items: build_list(:invoice_item, 1), project: project)
    login_as_role :administrator
    assert_authorized :show, { project_id: project.id, id: invoice.id }
  end

  test '#show is not viewable by leaders' do
    project = create(:project, account_id: 1)
    invoice = create(:invoice, invoice_items: build_list(:invoice_item, 1), project: project)
    login_as_role :leader
    assert_not_authorized :show, { project_id: project.id, id: invoice.id }
  end

  test '#show is not viewable by members' do
    project = create(:project, account_id: 1)
    invoice = create(:invoice, invoice_items: build_list(:invoice_item, 1), project: project)
    login_as_role :member
    assert_not_authorized :show, { project_id: project.id, id: invoice.id }
  end

  test '#new is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :new, { project_id: 1 }
  end

  test '#new is viewable by administrators' do
    login_as_role :administrator
    assert_authorized :new, { project_id: 1 }
  end

  test '#new is not viewable by leaders' do
    login_as_role :leader
    assert_not_authorized :new, { project_id: 1 }
  end

  test '#new is not viewable by members' do
    login_as_role :member
    assert_not_authorized :new, { project_id: 1 }
  end

  test '#create is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :create, { project_id: 1, invoice: attributes_for(:invoice) }, :post
  end

  test '#create is viewable by administrators' do
    login_as_role :administrator
    assert_authorized :create, { project_id: 1, invoice: attributes_for(:invoice) }, :post
  end

  test '#create is not viewable by leaders' do
    login_as_role :leader
    assert_not_authorized :create, { project_id: 1, invoice: attributes_for(:invoice) }, :post
  end

  test '#create is not viewable by members' do
    login_as_role :member
    assert_not_authorized :create, { project_id: 1, invoice: attributes_for(:invoice) }, :post
  end

  test '#change_status is viewable by account_holders' do
    project = create(:project, account_id: 1)
    invoice = create(:invoice, invoice_items: build_list(:invoice_item, 1), project: project)
    login_as_role :account_holder
    assert_authorized :change_status, { project_id: project.id, id: invoice.id }
  end

  test '#change_status is viewable by administrators' do
    project = create(:project, account_id: 1)
    invoice = create(:invoice, invoice_items: build_list(:invoice_item, 1), project: project)
    login_as_role :administrator
    assert_authorized :change_status, { project_id: project.id, id: invoice.id }
  end

  test '#change_status is not viewable by leaders' do
    project = create(:project, account_id: 1)
    invoice = create(:invoice, invoice_items: build_list(:invoice_item, 1), project: project)
    login_as_role :leader
    assert_not_authorized :change_status, { project_id: project.id, id: invoice.id }
  end

  test '#change_status is not viewable by members' do
    project = create(:project, account_id: 1)
    invoice = create(:invoice, invoice_items: build_list(:invoice_item, 1), project: project)
    login_as_role :member
    assert_not_authorized :destroy, { project_id: project.id, id: invoice.id }, :delete
  end

  test '#destroy is viewable by account_holders' do
    project = create(:project, account_id: 1)
    invoice = create(:invoice, invoice_items: build_list(:invoice_item, 1), project: project)
    login_as_role :account_holder
    assert_authorized :destroy, { project_id: project.id, id: invoice.id }, :delete
  end

  test '#destroy is viewable by administrators' do
    project = create(:project, account_id: 1)
    invoice = create(:invoice, invoice_items: build_list(:invoice_item, 1), project: project)
    login_as_role :administrator
    assert_authorized :destroy, { project_id: project.id, id: invoice.id }, :delete
  end

  test '#destroy is not viewable by leaders' do
    project = create(:project, account_id: 1)
    invoice = create(:invoice, invoice_items: build_list(:invoice_item, 1), project: project)
    login_as_role :leader
    assert_not_authorized :destroy, { project_id: project.id, id: invoice.id }, :delete
  end

  test '#destroy is not viewable by members' do
    project = create(:project, account_id: 1)
    invoice = create(:invoice, invoice_items: build_list(:invoice_item, 1), project: project)
    login_as_role :member
    assert_not_authorized :destroy, { project_id: project.id, id: invoice.id }, :delete
  end
 
end