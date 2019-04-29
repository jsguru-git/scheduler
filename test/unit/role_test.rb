require 'test_helper'

class RoleTest < ActiveSupport::TestCase

    test "title is present" do
        role = Role.new(:title => nil)
        assert_equal role.valid?, false
    end
   
end
