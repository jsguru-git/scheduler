require 'test_helper'

class ClientRateCardsControllerTest < ActionController::TestCase


  def setup
    change_host_to(:accounts_001)
    login_as(:users_001)
    @permitted_read = [:account_holder, :administrator, :leader, :member]
    @permitted_write = [:account_holder]
  end

  test "should show all rates for a given client" do
    get :index, :client_id => clients(:clients_001).id
    assert :success
    assert_not_nil assigns(:rate_cards)
  end

  test '#index authorizes permitted' do
    @permitted_read.each do |role|
      login_as_role role
      get :index, :client_id => clients(:clients_001).id
      assert_response :success
    end
  end

  test '#index does not allow excluded' do
    (roles - @permitted_read).each do |role|
      login_as_role role
      get :index, :client_id => clients(:clients_001).id
      assert_redirected_to root_url
    end
  end

  test "should get new override form" do
    get :new, :client_id => clients(:clients_001).id, :rate_card_id => rate_cards(:rate_cards_002).id
    assert :success
    assert_not_nil assigns(:rate_card)
    assert_not_nil assigns(:client_rate_card)
  end

  test '#new authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role
      get :new, :client_id => clients(:clients_001).id, :rate_card_id => rate_cards(:rate_cards_002).id
      assert_response :success
    end
  end

  test '#new does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      get :new, :client_id => clients(:clients_001).id, :rate_card_id => rate_cards(:rate_cards_002).id
      assert_redirected_to root_url
    end
  end

  test "should post to create override" do
    assert_difference 'ClientRateCard.all.length', +1 do
      post :create, :client_id => clients(:clients_001).id, :client_rate_card => {:rate_card_id => rate_cards(:rate_cards_002).id, :daily_cost => '100'}
      assert :redirect
    end
  end

  test "should post to create override but fail due invalid data" do
    assert_no_difference 'ClientRateCard.all.length' do
      post :create, :client_id => clients(:clients_001).id, :client_rate_card => {:rate_card_id => rate_cards(:rate_cards_002).id, :daily_cost => ''}
      assert :success
    end
  end

  test '#create authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role
      post :create, :client_id => clients(:clients_001).id, :client_rate_card => {:rate_card_id => rate_cards(:rate_cards_002).id, :daily_cost => '100'}
      assert_redirected_to client_client_rate_cards_path(clients(:clients_001))
    end
  end

  test '#create does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      post :create, :client_id => clients(:clients_001).id, :client_rate_card => {:rate_card_id => rate_cards(:rate_cards_002).id, :daily_cost => '100'}
      assert_redirected_to root_url
    end
  end

  test "should get update custom rate form" do
    get :edit, :client_id => clients(:clients_001).id, :id => client_rate_cards(:one).id
    assert :success
    assert_not_nil assigns(:client_rate_card)
  end

  test '#edit authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role
      get :edit, :client_id => clients(:clients_001).id, :id => client_rate_cards(:one).id
      assert_response :success
    end
  end

  test '#edit does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      get :edit, :client_id => clients(:clients_001).id, :id => client_rate_cards(:one).id
      assert_redirected_to root_url
    end
  end

  test "should update custom rate" do
    assert_no_difference 'ClientRateCard.all.length' do
      put :update, :client_id => clients(:clients_001).id, :id => client_rate_cards(:one).id, :client_rate_card => {:daily_cost => '100'}
      assert :redirect
    end
  end

  test '#update authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role
      put :update, :client_id => clients(:clients_001).id, :id => client_rate_cards(:one).id, :client_rate_card => {:daily_cost => '100'}
      assert_redirected_to client_client_rate_cards_path(clients(:clients_001))
    end
  end

  test '#update does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      put :update, :client_id => clients(:clients_001).id, :id => client_rate_cards(:one).id, :client_rate_card => {:daily_cost => '100'}
      assert_redirected_to root_url
    end
  end

  test "should update custom rate but fail due to blank amount" do
    assert_no_difference 'ClientRateCard.all.length' do
      put :update, :client_id => clients(:clients_001).id, :id => client_rate_cards(:one).id, :client_rate_card => {:daily_cost => ''}
      assert :success
    end
  end

  test "should remove custom rate from client" do
    assert_difference 'ClientRateCard.all.length', -1 do
      delete :destroy, :client_id => clients(:clients_001).id, :id => client_rate_cards(:one).id
    end
  end

  test '#destroy authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role
      delete :destroy, :client_id => clients(:clients_001).id, :id => client_rate_cards(:one).id
      assert_redirected_to client_client_rate_cards_path(clients(:clients_001))
    end
  end

  test '#destroy does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      delete :destroy, :client_id => clients(:clients_001).id, :id => client_rate_cards(:one).id
      assert_redirected_to root_url
    end
  end

end
