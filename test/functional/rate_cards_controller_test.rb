require 'test_helper'

class RateCardsControllerTest < ActionController::TestCase


  def setup
    set_ssl_request
    change_host_to(:accounts_001)
    login_as(:users_001)
    @permitted = [:account_holder]
  end


  test "Should get default rate card list" do
    get :index
    assert_response :success
    assert_not_nil assigns(:rate_cards)
  end

  test '#index authorizes permitted' do
    @permitted.each do |role|
      login_as_role role
      get :index
      assert_response :success
    end
  end

  test '#index does not allow excluded' do
    (roles - @permitted).each do |role|
      login_as_role role
      get :index
      assert_redirected_to root_url
    end
  end

  test "should get new rate card form" do
    get :new
    assert_response :success
    assert_not_nil assigns(:rate_card)
  end

  test '#new authorizes permitted' do
    @permitted.each do |role|
      login_as_role role
      get :new
      assert_response :success
    end
  end

  test '#new does not allow excluded' do
    (roles - @permitted).each do |role|
      login_as_role role
      get :new
      assert_redirected_to root_url
    end
  end

  test "should create a new rate card" do
    assert_difference 'RateCard.all.length', +1 do
      post :create, :rate_card => {:service_type => 'another service', :daily_cost => '44.59'}
      assert_response :redirect
    end
  end

  test '#create authorizes permitted' do
    @permitted.each do |role|
      login_as_role role
      post :create, :rate_card => {:service_type => 'another service', :daily_cost => '44.59'}
      assert_redirected_to rate_cards_path
    end
  end

  test '#create does not allow excluded' do
    (roles - @permitted).each do |role|
      login_as_role role
      post :create, :rate_card => {:service_type => 'another service', :daily_cost => '44.59'}
      assert_redirected_to root_url
    end
  end

  test "should create a new rate card but fila due to validation" do
    assert_no_difference 'RateCard.all.length' do
      post :create, :rate_card => {:service_type => '', :daily_cost => '44.59'}
      assert_response :success
    end
  end

  test "should get edit form" do
    get :edit, :id => accounts(:accounts_001).rate_cards.first.id
    assert_response :success
    assert_not_nil assigns(:rate_card)
  end

  test '#edit authorizes permitted' do
    @permitted.each do |role|
      login_as_role role
      get :edit, :id => accounts(:accounts_001).rate_cards.first.id
      assert_response :success
    end
  end

  test '#edit does not allow excluded' do
    (roles - @permitted).each do |role|
      login_as_role role
      get :edit, :id => accounts(:accounts_001).rate_cards.first.id
      assert_redirected_to root_url
    end
  end

  test "should update rate card" do
    assert_no_difference 'RateCard.all.length' do
      put :update, :id => accounts(:accounts_001).rate_cards.first.id, :rate_card => {:service_type => 'test'}
      assert_response :redirect
      assert_not_nil assigns(:rate_card)
    end
  end

  test "should update rate card but fail due to no name" do
    assert_no_difference 'RateCard.all.length' do
      put :update, :id => accounts(:accounts_001).rate_cards.first.id, :rate_card => {:service_type => ''}
      assert_response :success
      assert_not_nil assigns(:rate_card)
    end
  end

  test '#update authorizes permitted' do
    @permitted.each do |role|
      login_as_role role
      put :update, :id => accounts(:accounts_001).rate_cards.first.id, :rate_card => {:service_type => 'test'}
      assert_redirected_to rate_cards_path
    end
  end

  test '#update does not allow excluded' do
    (roles - @permitted).each do |role|
      login_as_role role
      put :update, :id => accounts(:accounts_001).rate_cards.first.id, :rate_card => {:service_type => 'test'}
      assert_redirected_to root_url
    end
  end

  test "should remove rate card" do
    assert_difference 'RateCard.all.length', -1 do
      delete :destroy, :id => accounts(:accounts_001).rate_cards.first.id
      assert_response :redirect
    end
  end

  test '#destroy authorizes permitted' do
    @permitted.each do |role|
      login_as_role role
      delete :destroy, :id => accounts(:accounts_001).rate_cards.first.id
      assert_redirected_to rate_cards_path
    end
  end

  test '#destroy does not allow excluded' do
    (roles - @permitted).each do |role|
      login_as_role role
      delete :destroy, :id => accounts(:accounts_001).rate_cards.first.id
      assert_redirected_to root_url
    end
  end
end
