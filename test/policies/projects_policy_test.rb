require 'test_helper'
require 'policies/policies_test'

class ProjectsPolicyTest < PoliciesTest

  def setup
    change_host_to(:accounts_001)
    @controller = ProjectsController.new
  end

  test '#index is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :index
  end

  test '#index is viewable by administrators' do
    login_as_role :administrator
    assert_authorized :index
  end

  test '#index is viewable by leaders' do
    login_as_role :leader
    assert_authorized :index
  end

  test '#index is not viewable by members' do
    login_as_role :member
    assert_not_authorized :index
  end

  test '#show is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :show, { id: 1 }
  end

  test '#show is viewable by administrators' do
    login_as_role :administrator
    assert_authorized :show, { id: 1 }
  end

  test '#show is viewable by leaders' do
    login_as_role :leader
    assert_authorized :show, { id: 1 }
  end

  test '#show is not viewable by members' do
    login_as_role :member
    assert_not_authorized :show, { id: 1 }
  end

  test '#new is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :new
  end

  test '#new is not viewable by administrators' do
    login_as_role :administrator
    assert_not_authorized :new
  end

  test '#new is not viewable by leaders' do
    login_as_role :leader
    assert_not_authorized :new
  end

  test '#new is not viewable by members' do
    login_as_role :member
    assert_not_authorized :new
  end

  test '#create is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :create, attributes_for(:project), :post
  end

  test '#create is not viewable by administrators' do
    login_as_role :administrator
    assert_not_authorized :create, attributes_for(:project), :post
  end

  test '#create is not viewable by leaders' do
    login_as_role :leader
    assert_not_authorized :create, attributes_for(:project), :post
  end

  test '#create is not viewable by members' do
    login_as_role :member
    assert_not_authorized :create, attributes_for(:project), :post
  end

  test '#update is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :update, { id: 1, project: { name: 'new name' } }, :put
  end

  test '#update is viewable by administrators' do
    login_as_role :administrator
    assert_authorized :update, { id: 1, project: { name: 'new name' } }, :put
  end

  test '#update is not viewable by leaders' do
    login_as_role :leader
    assert_not_authorized :update, { id: 1, project: { name: 'new name' } }, :put
  end

  test '#update is not viewable by members' do
    login_as_role :member
    assert_not_authorized :update, { id: 1, project: { name: 'new name' } }, :put
  end

  test '#edit_percentage_complete is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :edit_percentage_complete, { id: 1 }
  end

  test '#edit_percentage_complete is viewable by administrators' do
    login_as_role :administrator
    assert_authorized :edit_percentage_complete, { id: 1 }
  end

  test '#edit_percentage_complete is not viewable by leaders' do
    login_as_role :leader
    assert_not_authorized :edit_percentage_complete, { id: 1 }
  end

  test '#edit_percentage_complete is not viewable by members' do
    login_as_role :member
    assert_not_authorized :edit_percentage_complete, { id: 1 }
  end

  test '#update_percentage_complete is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :update_percentage_complete, { id: 1, project: { percentage_complete: 10 } }, :put
  end

  test '#update_percentage_complete is viewable by administrators' do
    login_as_role :administrator
    assert_authorized :update_percentage_complete, { id: 1, project: { percentage_complete: 10 } }, :put
  end

  test '#update_percentage_complete is not viewable by leaders' do
    login_as_role :leader
    assert_not_authorized :update_percentage_complete, { id: 1, project: { percentage_complete: 10 } }, :put
  end

  test '#update_percentage_complete is not viewable by members' do
    login_as_role :member
    assert_not_authorized :update_percentage_complete, { id: 1, project: { percentage_complete: 10 } }, :put
  end

  test '#archive is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :archive, { id: 1 }, :put
  end

  test '#archive is viewable by administrators' do
    login_as_role :administrator
    assert_authorized :archive, { id: 1 }, :put
  end

  test '#archive is not viewable by leaders' do
    login_as_role :leader
    assert_not_authorized :archive, { id: 1 }, :put
  end

  test '#archive is not viewable by members' do
    login_as_role :member
    assert_not_authorized :archive, { id: 1 }, :put
  end

  test '#schedule is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :schedule, { id: 1 }
  end

  test '#schedule is viewable by administrators' do
    login_as_role :administrator
    assert_authorized :schedule, { id: 1 }
  end

  test '#schedule is viewable by leaders' do
    login_as_role :leader
    assert_authorized :schedule, { id: 1 }
  end

  test '#schedule is viewable by members' do
    login_as_role :member
    assert_not_authorized :schedule, { id: 1 }
  end

  test '#track is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :track, { id: 1 }
  end

  test '#track is viewable by administrators' do
    login_as_role :administrator
    assert_authorized :track, { id: 1 }
  end

  test '#track is viewable by leaders' do
    login_as_role :leader
    assert_authorized :track, { id: 1 }
  end

  test '#track is viewable by members' do
    login_as_role :member
    assert_not_authorized :track, { id: 1 }
  end

  test '#activate is viewable by account_holders' do
    login_as_role :account_holder
    assert_authorized :activate, { id: 1 }, :put
  end

  test '#activate is not viewable by administrators' do
    login_as_role :administrator
    assert_authorized :activate, { id: 1 }, :put
  end

  test '#activate is not viewable by leaders' do
    login_as_role :leader
    assert_not_authorized :activate, { id: 1 }, :put
  end

  test '#activate is not viewable by members' do
    login_as_role :member
    assert_not_authorized :activate, { id: 1 }, :put
  end

end