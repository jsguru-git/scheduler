require 'test_helper'

class CloudStorage::CloudStorageTest < ActiveSupport::TestCase

  test '.start raises ArgumentError if provider is invalid' do
    assert_raises ArgumentError do
      CloudStorage::Base.start(:fake_provider, build(:user))
    end
  end

end