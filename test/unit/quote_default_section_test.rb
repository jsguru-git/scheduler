require 'test_helper'

class QuoteDefaultSectionTest < ActiveSupport::TestCase
  
  
  test "should create a new quote default section" do
    assert_difference 'QuoteDefaultSection.count', +1 do
      quote_section = accounts(:accounts_001).quote_default_sections.new(:title => 'test', :content => 'test')
      assert quote_section.save!
    end
  end
  
  
end
