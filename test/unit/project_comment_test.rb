require 'test_helper'

class ProjectCommentTest < ActiveSupport::TestCase
  
  
  test "should get the replied to comment" do
    assert_not_nil project_comments(:project_comments_003).project_comment_replied_to
  end
  
  
  test "should get all the replies to a comment" do
    assert_not_nil project_comments(:project_comments_002).project_comment_replies
  end
  
  
  test "should create a comment" do
    comment = projects(:projects_001).project_comments.new(:comment => 'test comment')
    comment.user_id = users(:users_001).id
    assert comment.save
  end
  
  
  test "should check project and user belong to same account on save" do
    comment = projects(:projects_001).project_comments.new(:comment => 'test comment')
    comment.user_id = users(:users_002).id
    assert_equal false, comment.save
    assert comment.errors[:user_id].present?
  end
  
  
  test "should reply to an existing comment" do
    comment = projects(:projects_001).project_comments.new(:comment => 'test comment', :project_comment_id => project_comments(:project_comments_001).id)
    comment.user_id = users(:users_001).id
    assert comment.save!
  end
  
  
  test "should reply to an exisitng comment but fail as they belong to different projects" do
    comment = projects(:projects_002).project_comments.new(:comment => 'test comment', :project_comment_id => project_comments(:project_comments_001).id)
    comment.user_id = users(:users_002).id
    assert_equal false, comment.save
    assert comment.errors[:project_comment_id].present?
  end
  
  
end
