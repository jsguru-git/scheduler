require 'test_helper'
require 'policies/policies_test'

class Quote::QuotesPolicyTest < PoliciesTest

  def setup
    change_host_to(:accounts_001)
    @controller = Quote::QuotesController.new
    @project = create(:project)
    @quote = create(:quote, project_id: @project.id)
  end

  test '#index is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :index, { project_id: @project.id }
  end

  test '#index is viewable by administrators' do
    login_as_role :administrator
    assert_authorized :index, { project_id: @project.id }
  end

  test '#index is viewable by leaders' do
    login_as_role :leader
    assert_authorized :index, { project_id: @project.id }
  end

  test '#index is not viewable by members' do
    login_as_role :member
    assert_not_authorized :index, { project_id: @project.id }
  end

  test '#create is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :create, { project_id: @project.id }, :post
  end

  test '#create is not viewable by administrators' do
    login_as_role :administrator
    assert_not_authorized :create, { project_id: @project.id }, :post
  end

  test '#create is not viewable by leaders' do
    login_as_role :leader
    assert_not_authorized :create, { project_id: @project.id }, :post
  end

  test '#create is not viewable by members' do
    login_as_role :member
    assert_not_authorized :create, { project_id: @project.id }, :post
  end

  test '#update is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :update, { project_id: @project.id, id: @project.quotes.first.id }, :put
  end

  test '#update is not viewable by administrators' do
    login_as_role :administrator
    assert_not_authorized :update, { project_id: @project.id, id: @project.quotes.first.id }, :put
  end

  test '#update is not viewable by leaders' do
    login_as_role :leader
    assert_not_authorized :update, { project_id: @project.id, id: @project.quotes.first.id }, :put
  end

  test '#update is not viewable by members' do
    login_as_role :member
    assert_not_authorized :update, { project_id: @project.id, id: @project.quotes.first.id }, :put
  end

  test '#show is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :show, { id: @quote.id, project_id: @project.id }
  end

  test '#show is viewable by administrators' do
    login_as_role :administrator
    assert_authorized :show, { id: @quote.id, project_id: @project.id }
  end

  test '#show is viewable by leaders' do
    login_as_role :leader
    assert_authorized :show, { id: @quote.id, project_id: @project.id }
  end

  test '#show is not viewable by members' do
    login_as_role :member
    assert_not_authorized :show, { id: @quote.id, project_id: @project.id }
  end

  test '#edit_details is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :edit_details, { id: @quote.id, project_id: @project.id, field: 'example' }
  end

  test '#edit_details is not viewable by administrators' do
    login_as_role :administrator
    assert_not_authorized :edit_details, { id: @quote.id, project_id: @project.id }
  end

  test '#edit_details is not viewable by leaders' do
    login_as_role :leader
    assert_not_authorized :edit_details, { id: @quote.id, project_id: @project.id }
  end

  test '#edit_details is not viewable by members' do
    login_as_role :member
    assert_not_authorized :edit_details, { id: @quote.id, project_id: @project.id }
  end

  test '#update_details is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :update_details, { id: @quote.id, project_id: @project.id }
  end

  test '#update_details is not viewable by administrators' do
    login_as_role :administrator
    assert_not_authorized :update_details, { id: @quote.id, project_id: @project.id }
  end

  test '#update_details is not viewable by leaders' do
    login_as_role :leader
    assert_not_authorized :update_details, { id: @quote.id, project_id: @project.id }
  end

  test '#update_details is not viewable by members' do
    login_as_role :member
    assert_not_authorized :update_details, { id: @quote.id, project_id: @project.id }
  end

  test '#copy_from_previous is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :copy_from_previous, { id: @quote.id, project_id: @project.id }
  end

  test '#copy_from_previous is not viewable by administrators' do
    login_as_role :administrator
    assert_not_authorized :copy_from_previous, { id: @quote.id, project_id: @project.id }
  end

  test '#copy_from_previous is not viewable by leaders' do
    login_as_role :leader
    assert_not_authorized :copy_from_previous, { id: @quote.id, project_id: @project.id }
  end

  test '#copy_from_previous is not viewable by members' do
    login_as_role :member
    assert_not_authorized :copy_from_previous, { id: @quote.id, project_id: @project.id }
  end

  test '#destroy is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :destroy, { id: @quote.id, project_id: @project.id }
  end

  test '#destroy is not viewable by administrators' do
    login_as_role :administrator
    assert_not_authorized :destroy, { id: @quote.id, project_id: @project.id }
  end

  test '#destroy is not viewable by leaders' do
    login_as_role :leader
    assert_not_authorized :destroy, { id: @quote.id, project_id: @project.id }
  end

  test '#destroy is not viewable by members' do
    login_as_role :member
    assert_not_authorized :destroy, { id: @quote.id, project_id: @project.id }
  end
 
end