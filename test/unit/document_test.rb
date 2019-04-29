require 'test_helper'

class DocumentTest < ActiveSupport::TestCase
  
  
  test "should check user relationship" do
    assert_not_nil documents(:documents_001).user
    assert_kind_of User, documents(:documents_001).user
  end
  
  
  test "should check project relationship" do
    assert_not_nil documents(:documents_001).project
    assert_kind_of Project, documents(:documents_001).project
  end
  
  
  test "should check comments relationship" do
    assert_not_nil documents(:documents_001).document_comments
    assert_kind_of Array, documents(:documents_001).document_comments
    assert_kind_of DocumentComment, documents(:documents_001).document_comments.first
  end
  
  
  test "should check validation on user and project belonging got the same account" do
    documents(:documents_001).user_id = users(:users_002).id
    assert_equal false, documents(:documents_001).save
    assert documents(:documents_001).errors[:project_id].present?
  end
  
  
  test "should check if is a local file upload" do
    assert_equal false, documents(:documents_001).is_local?
    assert_equal true, documents(:documents_004).is_local?
  end
  
  
end
