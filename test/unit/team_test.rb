require 'test_helper'

class TeamTest < ActiveSupport::TestCase

    test "should create new team" do
        assert_difference 'Team.all.length', +1 do
            accounts(:accounts_001).teams.create(:name => 'new team name')
        end
    end

    test "should edit team" do
        assert_no_difference 'Team.all.length' do
            teams(:teams_001).update_attributes(:name => 'new team name')
        end
    end

    test "should remove whitespace on create" do
        team = accounts(:accounts_001).teams.create(:name => ' new team name ')
        assert_equal 'new team name', team.name
    end

    test "should check if user is tagged to team" do
        team = teams(:teams_001)
        assert team.is_user_tagged_to_team?(teams(:teams_001).users.first)
    end

    test "should be able to access project as they are the account holder" do
        assert teams(:teams_001).can_user_access?(users(:users_001))
    end

    test "should be able to access project as they are tagged" do
        assert teams(:teams_001).can_user_access?(users(:users_006))
    end    
end
