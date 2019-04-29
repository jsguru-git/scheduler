require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase

  test 'should not define protocol by default' do
    assert_equal 'https://domain.com/image.png', s3_image('//domain.com/image.png', protocol: 'https://')
  end

  test 'should prepend protocol when defined' do
    assert_equal 'https://domain.com/image.png', s3_image('//domain.com/image.png', protocol: 'https://')
  end
end
