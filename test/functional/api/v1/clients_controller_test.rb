require 'test_helper'

class Api::V1::ClientsControllerTest < ActionController::TestCase

  def setup
    change_host_to(:accounts_001)
    @request.env['HTTPS'] = 'on'
    @request.env['HTTP_AUTHORIZATION'] = 'Token token="fe65859688b32b921168a360611e8e4f"'
  end

  test 'index: display all clients' do
    get :index, format: :json
    assert_not_nil assigns(:clients)
    assert_response :success
  end

  test 'index: no response for html' do
    assert_raises ActionView::MissingTemplate do
      get :index, format: :html
    end
  end

  test 'show: display one client' do
    get :show, format: :json, id: 1
    assert_equal 1, assigns(:client).first.id
  end

  test 'show: no response for html' do
    assert_raises ActionView::MissingTemplate do
      get :show, format: :html, id: 1
    end
  end

  test 'profit_and_loss: no resposne for html' do
    assert_raises ActionView::MissingTemplate do
      get :profit_and_loss, format: :html, id: 1
    end
  end

  test 'profit_and_loss: uses default start date if one does not exist' do
    Delorean.time_travel_to("now") do
      get :profit_and_loss, format: :json, id: 1
      assert_equal 1.year.ago.to_date, assigns(:start_date).to_date
    end
  end

  test 'profit_and_loss: uses default end date if one does not exist' do
    Delorean.time_travel_to("now") do
      get :profit_and_loss, format: :json, id: 1
      assert_equal Date.today, assigns(:end_date).to_date
    end
  end

  test 'profit_and_loss: uses specified start date if one given' do
    Delorean.time_travel_to("5th August 2013") do
      get :profit_and_loss, format: :json, start_date: '2013-08-01', id: 1
      assert_equal '2013-08-01'.to_datetime, assigns(:start_date)
    end
  end

  test 'profit_and_loss: uses specified end date if one given' do
    get :profit_and_loss, format: :json, end_date: '2013-08-12', id: 1
    assert_equal '2013-08-12'.to_datetime, assigns(:end_date)
  end

  test 'authentication fails by default' do
    @request.env['HTTP_AUTHORIZATION'] = nil
    get :index, format: :json, id: 1
    assert_response :unauthorized
  end

  test 'fails with incorrect API key' do
    @request.env['HTTP_AUTHORIZATION'] = 'fakeapikey'
    get :index, format: :json, id: 1
    assert_response :unauthorized
  end

  test 'fails with API key for incorrect account' do
    @request.env['HTTP_AUTHORIZATION'] = 'Token token="5897e9322360906ab2de9075c0bb2617"'
    get :index, format: :json, id: 1
    assert_response :unauthorized
  end

  test 'succeeds with correct authentication' do
    @request.env['HTTP_AUTHORIZATION'] = 'Token token="fe65859688b32b921168a360611e8e4f"'
    get :index, format: :json, id: 1
    assert_response :success
  end

  test 'something happens when SSL isnt on' do
    @request.env['HTTPS'] = 'off'
    get :index, format: :json, id: 1
    assert_response :redirect
  end


end