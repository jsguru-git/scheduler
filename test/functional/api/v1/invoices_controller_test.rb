require 'test_helper'

class Api::V1::InvoicesControllerTest < ActionController::TestCase

  def setup
    change_host_to(:accounts_001)
    @request.env['HTTPS'] = 'on'
    @request.env['HTTP_AUTHORIZATION'] = 'Token token="fe65859688b32b921168a360611e8e4f"'
  end

  test 'index: display all invoices' do
    get :index, format: :json
    assert_equal 2, assigns(:invoices).size
    assert_response :success
  end

  test 'index: no response for html' do
    assert_raises ActionView::MissingTemplate do
      get :index, format: :html
    end
  end

  test 'index: uses default start date if one does not exist' do
    Delorean.time_travel_to("now") do
      get :index, format: :json
      assert_equal 1.year.ago.to_date, assigns(:start_date).to_date
    end
  end

  test 'index: uses default end date if one does not exist' do
    Delorean.time_travel_to("now") do
      get :index, format: :json
      assert_equal Date.today, assigns(:end_date).to_date
    end
  end

  test 'index: uses specified start date if one given' do
    Delorean.time_travel_to("5th August 2013") do
      get :index, format: :json, start_date: '2013-08-01'
      assert_equal '2013-08-01'.to_datetime, assigns(:start_date)
    end
  end

  test 'index: uses specified end date if one given' do
    get :index, format: :json, end_date: '2013-08-12'
    assert_equal '2013-08-12'.to_datetime, assigns(:end_date)
  end

  test 'show: display one invoice' do
    get :show, format: :json, id: 1
    assert_equal 1, assigns(:invoice).first.id
  end

  test 'show: no response for html' do
    assert_raises ActionView::MissingTemplate do
      get :show, format: :html, id: 1
    end
  end

  test 'due: no resposne for html' do
    assert_raises ActionView::MissingTemplate do
      get :due, format: :html
    end
  end

  test 'due: uses default start date if one does not exist' do
    Delorean.time_travel_to("now") do
      get :due, format: :json
      assert_equal 1.year.ago.to_date, assigns(:start_date).to_date
    end
  end

  test 'due: uses default end date if one does not exist' do
    Delorean.time_travel_to("now") do
      get :due, format: :json
      assert_equal 30.days.from_now.to_date, assigns(:end_date).to_date
    end
  end

  test 'due: uses specified start date if one given' do
    Delorean.time_travel_to("5th August 2013") do
      get :due, format: :json, start_date: '2013-08-01'
      assert_equal '2013-08-01'.to_datetime, assigns(:start_date)
    end
  end

  test 'due: uses specified end date if one given' do
    get :due, format: :json, end_date: '2013-08-12'
    assert_equal '2013-08-12'.to_datetime, assigns(:end_date)
  end

  test 'allocated: no response for html' do
    assert_raises ActionView::MissingTemplate do
      get :allocated, format: :html
    end
  end

  test 'allocated: returns correct amount' do
    get :allocated, format: :json
    assert_equal 150, assigns(:amount)
  end

  test 'authentication fails by default' do
    @request.env['HTTP_AUTHORIZATION'] = nil
    get :index, format: :json
    assert_response :unauthorized
  end

  test 'fails with incorrect API key' do
    @request.env['HTTP_AUTHORIZATION'] = 'fakeapikey'
    get :index, format: :json
    assert_response :unauthorized
  end

  test 'fails with API key for incorrect account' do
    @request.env['HTTP_AUTHORIZATION'] = 'Token token="5897e9322360906ab2de9075c0bb2617"'
    get :index, format: :json
    assert_response :unauthorized
  end

  test 'succeeds with correct authentication' do
    @request.env['HTTP_AUTHORIZATION'] = 'Token token="fe65859688b32b921168a360611e8e4f"'
    get :index, format: :json
    assert_response :success
  end

  test 'something happens when SSL isnt on' do
    @request.env['HTTPS'] = 'off'
    get :index, format: :json
    assert_response :redirect
  end


end