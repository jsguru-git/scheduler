require 'test_helper'

class Api::V1::TeamsControllerTest < ActionController::TestCase

  def setup
    change_host_to(:accounts_001)
    @request.env['HTTPS'] = 'on'
    @request.env['HTTP_AUTHORIZATION'] = 'Token token="fe65859688b32b921168a360611e8e4f"'
  end

  test 'index: JSON GET request returns success' do
    get :index, format: :json

    assert :sucess
  end

  test 'show: JSON GET request returns success' do
    get :show, format: :json, id: 1

    assert :sucess
  end

  test 'entries: JSON GET request returns success' do
    get :entries, format: :json, id: 1

    assert :sucess
  end

  test 'entries: display all entries for a particular project' do
    get :entries, format: :json, id: 1

    assert_not_nil assigns(:entries)
  end

  test 'timings: JSON GET request returns success' do
    get :timings, format: :json, id: 1

    assert :sucess
  end

  test 'timings: display all timings for a particular project' do
    get :timings, format: :json, id: 1

    assert_not_nil assigns(:timings)
  end

  test 'timings: no response for html' do
    assert_raises ActionView::MissingTemplate do
      get :timings, format: :html, id: 1
    end
  end

end
