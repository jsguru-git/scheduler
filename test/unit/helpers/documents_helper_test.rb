require 'test_helper'

class DocumentsHelperTest < ActionView::TestCase
  test 'summary_helper returns a helpful summary for documents with a user that are attached' do
    assert_equal 'Attached by: Test User on 6th Jun 2013', summary_helper(documents(:documents_001))
  end

  test '#summary_helper returns a helpful summary for documents without a user that are not attached' do
    document = documents(:documents_001)
    document.stubs(:user).returns(nil)
    assert_equal 'Attached on 6th Jun 2013', summary_helper(documents(:documents_001))
  end
end
