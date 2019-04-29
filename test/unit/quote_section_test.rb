require 'test_helper'

class QuoteSectionTest < ActiveSupport::TestCase
  
  
  test "should create a new quote section" do
    assert_difference 'QuoteSection.count', +1 do
      quote_section = quotes(:quotes_002).quote_sections.new(:title => 'test', :content => 'test')
      assert quote_section.save!
    end
  end
  
  
  test "should create a new quote section and set quote to live" do
    quote_section = quotes(:quotes_004).quote_sections.new(:title => 'test', :content => 'test')
    assert quote_section.save!
    quotes(:quotes_004).reload
    assert_equal false, quotes(:quotes_004).draft?
  end
  
  
end
