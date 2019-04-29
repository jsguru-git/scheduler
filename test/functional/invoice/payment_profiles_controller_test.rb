require 'test_helper'

class Invoice::PaymentProfilesControllerTest < ActionController::TestCase
  
  
  def setup
    change_host_to(:accounts_001)
    login_as(:users_001)
    @project = create(:project)
    @payment_profile = create(:payment_profile)
    @permitted_read = [:account_holder, :administrator]
    @permitted_write = [:account_holder]
  end
  
  test "should list all payment profiles for a given project" do
    get :index, :project_id => projects(:projects_002)
    assert_response :success
    assert_not_nil assigns(:payment_profiles)
  end

  test '#index authorizes permitted' do
    @permitted_read.each do |role|
      login_as_role role

      get :index, project_id: @project.id
      assert_response :success
    end
  end

  test '#index does not allow excluded' do
    (roles - @permitted_read).each do |role|
      login_as_role role
      get :index, project_id: @project.id
      assert_redirected_to root_url
    end
  end
  
  
  test "should display new payment profile form" do
    get :new, :project_id => projects(:projects_002)
    assert_response :success
    assert_not_nil assigns(:payment_profile)
  end

  test '#new authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role

      get :new, project_id: @project.id
      assert_response :success
    end
  end

  test '#new does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      get :new, project_id: @project.id
      assert_redirected_to root_url
    end
  end
  
  test "should post payment profile form" do
    assert_difference 'PaymentProfile.all.length', +1 do
      post :create, :project_id => projects(:projects_002), :payment_profile => {:name => 'Sprint 1 start', :expected_cost => 44.55, :expected_payment_date => Date.today}
    end
    assert_response :redirect
    assert_not_nil assigns(:payment_profile)
    assert_equal 4455, assigns(:payment_profile).expected_cost_cents
  end
  
  
  test "should post payment profile form but fail due to validation" do
    assert_no_difference 'PaymentProfile.all.length' do
      post :create, :project_id => projects(:projects_002), :payment_profile => {:expected_cost => 44.55, :expected_payment_date => Date.today}
    end
    assert_response :success
    assert_not_nil assigns(:payment_profile)
    assert assigns(:payment_profile).errors[:name].present?
  end

  test '#create authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role

      get :create, project_id: @project.id
      assert_response :success
    end
  end

  test '#create does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      get :create, project_id: @project.id
      assert_redirected_to root_url
    end
  end
  
  test "should get edit payment profile" do
    get :edit, :project_id => projects(:projects_002), :id => payment_profiles(:payment_profiles_001).id
    assert_response :success
    assert_not_nil assigns(:payment_profile)
  end

  test '#edit authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role

      get :edit, project_id: @payment_profile.project.id, id: @payment_profile.id
      assert_response :success
    end
  end

  test '#edit does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      get :edit, project_id: @payment_profile.project.id, id: @payment_profile.id
      assert_redirected_to root_url
    end
  end
  
  test "should update existing record and succeed" do
    assert_no_difference 'PaymentProfile.all.length' do
      put :update, :project_id => projects(:projects_002), :id => payment_profiles(:payment_profiles_001).id, :payment_profile => {:name => 'Sprint 1 start'}
    end
    assert_response :redirect
    assert_not_nil assigns(:payment_profile)
    assert_not_nil assigns(:payment_profile).last_saved_by_id
    assert_equal 'Sprint 1 start', assigns(:payment_profile).name
  end
  
  
  test "should update existing record but fail due to validation" do
    assert_no_difference 'PaymentProfile.all.length' do
      put :update, :project_id => projects(:projects_002), :id => payment_profiles(:payment_profiles_001).id, :payment_profile => {:name => ''}
    end
    assert_response :success
    assert_not_nil assigns(:payment_profile)
    assert assigns(:payment_profile).errors[:name].present?
  end

  test '#update authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role

      put :update, project_id: @payment_profile.project.id, id: @payment_profile.id
      assert_response :redirect
      assert_not_nil assigns(:payment_profile)
    end
  end

  test '#update does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      put :update, project_id: @payment_profile.project.id, id: @payment_profile.id
      assert_redirected_to root_url
    end
  end
  
  test "should remove existing payment profile" do
    assert_difference 'PaymentProfile.all.length', -1 do
      delete :destroy, :project_id => projects(:projects_002), :id => payment_profiles(:payment_profiles_001).id
    end
    assert_response :redirect
  end

  test '#destroy authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role

      delete :destroy, project_id: @payment_profile.project.id, id: @payment_profile.id
      assert_response :redirect
    end
  end

  test '#destroy does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      delete :destroy, project_id: @payment_profile.project.id, id: @payment_profile.id
      assert_redirected_to root_url
    end
  end
  
  test "should remove existing payment profile but fail as its already been invoiced" do
    invoice_item = InvoiceItem.new(:quantity => 1, :vat => true, :name => 'test', :amount => 100)
    invoice_item.payment_profile_id = payment_profiles(:payment_profiles_001).id
    invoice_item.invoice_id = 1
    invoice_item.save(:validate => false)
    
    payment_profiles(:payment_profiles_001).save(:validate => false)
    assert_no_difference 'PaymentProfile.all.length' do
      delete :destroy, :project_id => projects(:projects_002), :id => payment_profiles(:payment_profiles_001).id
    end
    assert_response :redirect
  end
  
  
  test "should edit service types form" do
    get :edit_service_types, :project_id => projects(:projects_002), :id => payment_profiles(:payment_profiles_003).id
    assert_response :success
    assert_not_nil assigns(:payment_profile)
  end

  test '#edit_service_types authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role

      get :edit_service_types, project_id: @payment_profile.project.id, id: @payment_profile.id
      assert_response :success
    end
  end

  test '#edit_service_types does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      get :edit_service_types, project_id: @payment_profile.project.id, id: @payment_profile.id
      assert_redirected_to root_url
    end
  end
  
  test "should put update service types and update costs" do
    payment_profiles(:payment_profiles_003).rate_card_payment_profiles.first.delete
    
    assert_difference 'RateCardPaymentProfile.all.length', +1 do
      put :update_service_types, :project_id => projects(:projects_002), :id => payment_profiles(:payment_profiles_003).id, :payment_profile => {:rate_card_payment_profiles_attributes => [{:percentage => 50, :rate_card_id => rate_cards(:rate_cards_002).id}]}
    end
    assert_response :redirect
    assert_equal 1000.0, assigns(:payment_profile).expected_cost
  end
  
  test '#update_service_types authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role

      put :update_service_types, project_id: @payment_profile.project.id, id: @payment_profile.id
      assert_response :redirect
    end
  end

  test '#update_service_types does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      put :update_service_types, project_id: @payment_profile.project.id, id: @payment_profile.id
      assert_redirected_to root_url
    end
  end

  test "should put update service types and not update costs as being entered manually" do
    assert_difference 'RateCardPaymentProfile.all.length', +1 do
      put :update_service_types, :project_id => projects(:projects_002), :id => payment_profiles(:payment_profiles_002).id, :payment_profile => {:rate_card_payment_profiles_attributes => [{:percentage => 50, :rate_card_id => rate_cards(:rate_cards_002).id}]}
    end
    assert_response :redirect
    assert_equal 200.0, assigns(:payment_profile).expected_cost
  end
  
  
  test "should put update service types but fail validation due to having a 0% percentage" do
    payment_profiles(:payment_profiles_003).rate_card_payment_profiles.first.delete
    
    assert_no_difference 'RateCardPaymentProfile.all.length' do
      put :update_service_types, :project_id => projects(:projects_002), :id => payment_profiles(:payment_profiles_003).id, :payment_profile => {:rate_card_payment_profiles_attributes => [{:percentage => 0, :rate_card_id => rate_cards(:rate_cards_002).id}]}
    end
    assert_response :success
    assert_equal 1, assigns(:payment_profile).errors.full_messages.length
  end
  
  
  test "should show form to generate payment profile from schedule" do
    get :generate_from_schedule, :project_id => projects(:projects_002)
    assert_response :success
    assert_not_nil assigns(:auto_payment_profile)
    assert_not_nil assigns(:auto_payment_profile).start_date
    assert_not_nil assigns(:auto_payment_profile).end_date
  end
  
  test '#generate_from_schedule authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role

      get :generate_from_schedule, project_id: @payment_profile.project.id, id: @payment_profile.id
      assert_response :success
    end
  end

  test '#generate_from_schedule does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      get :generate_from_schedule, project_id: @payment_profile.project.id, id: @payment_profile.id
      assert_redirected_to root_url
    end
  end
  
  test "should post to create payment profile from schedule" do
    start_date = Time.new(2012,5,24).to_date
		end_date = start_date + 20.days
		
		assert_difference 'PaymentProfile.all.length', +2 do
      post :generate_from_schedule_save, :project_id => projects(:projects_001).id, :auto_payment_profile => {'start_date' => start_date, 'end_date' => end_date, :frequency => 1}
    end
    
    assert_response :redirect
  end

  test '#generate_from_schedule_save authorizes permitted' do
    start_date = Time.new(2012,5,24).to_date
    end_date = start_date + 20.days
    @permitted_write.each do |role|
      login_as_role role

      post :generate_from_schedule_save, :project_id => projects(:projects_001).id, :auto_payment_profile => {'start_date' => start_date, 'end_date' => end_date, :frequency => 1}
      assert_response :redirect
    end
  end

  test '#generate_from_schedule_save does not allow excluded' do
    start_date = Time.new(2012,5,24).to_date
    end_date = start_date + 20.days
    (roles - @permitted_write).each do |role|
      login_as_role role
      post :generate_from_schedule_save, :project_id => projects(:projects_001).id, :auto_payment_profile => {'start_date' => start_date, 'end_date' => end_date, :frequency => 1}
      assert_redirected_to root_url
    end
  end
  
  
end
