require 'test_helper'

class QaStatTest < ActiveSupport::TestCase
  
  test "should create a new qa stat" do
    assert_difference 'QaStat.count', +1 do
      projects(:projects_001).qa_stats.create!(ticket_breakdown: { total_tickets: 1, status: { minor: 1 } }, total_tickets: 1)
    end
  end
  
  test "should get qa stats headings for a set of qa stats" do
    headings = QaStat.get_all_column_headings_for(projects(:projects_002).qa_stats, :priority)
    assert_not_nil headings
  end
  
end
