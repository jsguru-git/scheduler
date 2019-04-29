# Report generator tests

require 'test_helper'
require 'api'

class ApiTest < ActiveSupport::TestCase
   test "get_total_capacity returns correct percentage capacity for a team" do
     d1 = [{:capacity => 100}, {:capacity => 50}]
     d2 = [{:capacity => 100}, {:capacity => 100}]
     assert_equal Api::Internal.get_total_capacity(d1), 75
     assert_equal Api::Internal.get_total_capacity(d2), 100
   end
end

