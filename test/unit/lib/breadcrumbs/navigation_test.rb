require 'test_helper'

class Breadcrumbs::NavigationTest < ActiveSupport::TestCase

  # .intialize
  test 'should initialize with an Array of breadcrumbs' do
    nav = Breadcrumbs::Navigation.new

    assert_equal Array, nav.breadcrumbs.class
  end

  # #add_breadcrumb
  test 'should increase the number of breadcrumbs' do
    nav = Breadcrumbs::Navigation.new

    assert_difference 'nav.breadcrumbs.size', 1 do
      nav.add_breadcrumb('Current', '/')
    end
  end

end
