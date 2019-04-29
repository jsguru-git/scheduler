require 'test_helper'

class FeatureTest < ActiveSupport::TestCase

    test "should create new feature" do
        assert_difference 'Feature.all.size', +1 do
            project = projects(:projects_001)
            project.features.create(:name => 'feature name')
        end
    end
    
    test "should update a new feature" do
        assert_no_difference 'Feature.all.size' do
            features(:features_001).update_attributes(:name => 'test another')
            assert_equal 'test another', features(:features_001).name
        end
    end
    
    test "should remove a feature" do
        assert_difference 'Feature.all.size', -1 do
            features(:features_001).destroy
        end
    end

end
