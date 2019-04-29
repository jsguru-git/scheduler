require 'test_helper'

class Breadcrumbs::BreadcrumbTest < ActiveSupport::TestCase

  # .intialize
  test 'should initialize with a title' do
    title = 'Dashboard'
    url = '/'
    breadcrumb = Breadcrumbs::Breadcrumb.new(title, url)

    assert_equal title, breadcrumb.title
  end

  test 'should initialize with a link' do
    title = 'Dashboard'
    url = '/'
    breadcrumb = Breadcrumbs::Breadcrumb.new(title, url)

    assert_equal url, breadcrumb.link
  end

end

