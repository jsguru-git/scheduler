require 'test_helper'

class DocumentCommentTest < ActiveSupport::TestCase
  
  
  test "should create a comment" do
    comment = documents(:documents_001).document_comments.new(:comment => 'test comment')
    comment.user_id = users(:users_001).id
    assert comment.save
  end
  
  
  test "should check document and user belong to same account on save" do
    comment = documents(:documents_001).document_comments.new(:comment => 'test comment')
    comment.user_id = users(:users_002).id
    assert_equal false, comment.save
    assert comment.errors[:user_id].present?
  end
  
  
end
