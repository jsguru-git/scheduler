require 'test_helper'

class Invoice::PaymentProfileRolloversControllerTest < ActionController::TestCase
  
  
  def setup
    change_host_to(:accounts_001)
    login_as(:users_001)
    set_ssl_request
    @rollover = create(:payment_profile_rollover)
    @permitted_read = [:account_holder, :administrator]
    @permitted_write = [:account_holder]
  end

  test '#edit authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role
      rollover = payment_profile_rollovers(:one)

      get :edit, { id: @rollover.id, project_id: @rollover.project.id, format: :js }
      assert_response :success
    end
  end

  test '#edit does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      get :edit, id: @rollover.id, project_id: @rollover.project.id, format: :js
      assert_redirected_to root_url
    end
  end

  test '#update authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role
      rollover = payment_profile_rollovers(:one)

      get :update, { id: @rollover.id, project_id: @rollover.project.id, format: :js }
      assert_response :success
    end
  end

  test '#update does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      get :update, id: @rollover.id, project_id: @rollover.project.id, format: :js
      assert_redirected_to root_url
    end
  end
  
end