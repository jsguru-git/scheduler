require 'test_helper'
require 'policies/policies_test'

class TasksPolicyTest < PoliciesTest

  def setup
    change_host_to(:accounts_001)
    @controller = TasksController.new
    @task = create(:task)
  end

  test '#index is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :index, { project_id: 1 }
  end

  test '#index is viewable by administrators' do
    login_as_role :administrator
    assert_authorized :index, { project_id: 1 }
  end

  test '#index is viewable by leaders' do
    login_as_role :leader
    assert_authorized :index, { project_id: 1 }
  end

  test '#index is not viewable by members' do
    login_as_role :member
    assert_not_authorized :index, { project_id: 1 }
  end

  test '#show is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :show, { project_id: 1, id: @task.id }
  end

  test '#show is viewable by administrators' do
    login_as_role :administrator
    assert_authorized :show, { project_id: 1, id: @task.id }
  end

  test '#show is viewable by leaders' do
    login_as_role :leader
    assert_authorized :show, { project_id: 1, id: @task.id }
  end

  test '#show is not viewable by members' do
    login_as_role :member
    assert_not_authorized :show, { project_id: 1, id: @task.id }
  end

  test '#new is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :new, { project_id: 1 }
  end

  test '#new is not viewable by administrators' do
    login_as_role :administrator
    assert_not_authorized :new, { project_id: 1 }
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
    assert_authorized :create, { project_id: 1, task: attributes_for(:task).delete_if{ |k, _| k == :project_id } }, :post
  end

  test '#create is not viewable by administrators' do
    login_as_role :administrator
    assert_not_authorized :create, { project_id: 1, task: attributes_for(:task).delete_if{ |k, _| k == :project_id } }, :post
  end

  test '#create is not viewable by leaders' do
    login_as_role :leader
    assert_not_authorized :create, { project_id: 1, task: attributes_for(:task).delete_if{ |k, _| k == :project_id } }, :post
  end

  test '#create is not viewable by members' do
    login_as_role :member
    assert_not_authorized :create, { project_id: 1, task: attributes_for(:task).delete_if{ |k, _| k == :project_id } }, :post
  end

  test '#destroy is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :destroy, { project_id: 1, id: @task.id }, :delete
  end

  test '#destroy is not vieable by administrators' do
    login_as_role :administrator
    assert_not_authorized :destroy, { project_id: 1, id: @task.id }, :delete
  end

  test '#destroy is not viewable by leaders' do
    login_as_role :leader
    assert_not_authorized :destroy, { project_id: 1, id: @task.id }, :delete
  end

  test '#destroy is not viewable by members' do
    login_as_role :member
    assert_not_authorized :destroy, { project_id: 1, id: @task.id }, :delete
  end

  test '#edit is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :edit, { project_id: 1, id: @task.id }
  end

  test '#edit is not vieable by administrators' do
    login_as_role :administrator
    assert_not_authorized :edit, { project_id: 1, id: @task.id }
  end

  test '#edit is not viewable by leaders' do
    login_as_role :leader
    assert_not_authorized :edit, { project_id: 1, id: @task.id }
  end

  test '#edit is not viewable by members' do
    login_as_role :member
    assert_not_authorized :edit, { project_id: 1, id: @task.id }
  end

  test '#update is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :update, { project_id: 1, id: @task.id }, :put
  end

  test '#update is not vieable by administrators' do
    login_as_role :administrator
    assert_not_authorized :update, { project_id: 1, id: @task.id }, :put
  end

  test '#update is not viewable by leaders' do
    login_as_role :leader
    assert_not_authorized :update, { project_id: 1, id: @task.id }, :put
  end

  test '#update is not viewable by members' do
    login_as_role :member
    assert_not_authorized :update, { project_id: 1, id: @task.id }, :put
  end

  test '#sort is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :sort, { project_id: 1 }
  end

  test '#sort is viewable by administrators' do
    login_as_role :administrator
    assert_authorized :sort, { project_id: 1 }
  end

  test '#sort is viewable by leaders' do
    login_as_role :leader
    assert_authorized :sort, { project_id: 1 }
  end

  test '#sort is not viewable by members' do
    login_as_role :member
    assert_not_authorized :sort, { project_id: 1 }
  end

  test '#new_import_quote is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :new_import_quote, { project_id: 1 }
  end

  test '#new_import_quote is not vieable by administrators' do
    login_as_role :administrator
    assert_not_authorized :new_import_quote, { project_id: 1 }
  end

  test '#new_import_quote is not viewable by leaders' do
    login_as_role :leader
    assert_not_authorized :new_import_quote, { project_id: 1 }
  end

  test '#new_import_quote is not viewable by members' do
    login_as_role :member
    assert_not_authorized :new_import_quote, { project_id: 1 }
  end

  test '#import_quote is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :import_quote, { project_id: 1, quote_id: 1 }, :post
  end

  test '#import_quote is not vieable by administrators' do
    login_as_role :administrator
    assert_not_authorized :import_quote, { project_id: 1, quote_id: 1 }, :post
  end

  test '#import_quote is not viewable by leaders' do
    login_as_role :leader
    assert_not_authorized :import_quote, { project_id: 1, quote_id: 1 }, :post
  end

  test '#import_quote is not viewable by members' do
    login_as_role :member
    assert_not_authorized :import_quote, { project_id: 1, quote_id: 1 }, :post
  end
 
end