require 'test_helper'

class TaskTest < ActiveSupport::TestCase

   def setup
     @task = tasks(:tasks_001)
   end
    
    
    test "Should create task associated with feature" do
        assert_difference 'Task.all.size', +1 do
            project = projects(:projects_002)
            project.tasks.create(:name => 'feature name') 
        end
    end


    test "Should create task not associated with feature" do
        assert_difference 'Task.all.size', +1 do
            project = projects(:projects_002)
            project.tasks.create(:name => 'feature name', :feature_id => projects(:projects_002).features.first.id) 
        end
    end


    test "Should check cant create task assocated with feature that doesnt belong to the same project" do
        assert_no_difference 'Task.all.size' do
            project = projects(:projects_002)
            task = project.tasks.create(:name => 'feature name', :feature_id => projects(:projects_001).features.first.id) 
            assert task.errors[:feature_id].present?
        end
    end


    test "should update task" do
        assert tasks(:tasks_001).update_attributes(:name => 'test1')
        assert_equal 'test1', tasks(:tasks_001).name
    end


    test "should remove task but fail if has associated timings" do
        assert_no_difference 'Task.all.size' do
            
            task = Task.find(tasks(:tasks_001).id)
            assert_raise ActiveRecord::DeleteRestrictionError do
                task.destroy
            end
            
        end
    end


    test "should remove task" do
        assert_difference 'Task.all.size', -1 do
            task = Task.find(tasks(:tasks_001).id)
            timings = task.timings
            timings.delete_all
            task.destroy
        end
    end
    
    test "time tracked minutes method" do
      assert @task.respond_to?(:time_tracked_minutes)
    end

    test "time_tracked_minutes returns integer" do
      assert @task.time_tracked_minutes.kind_of?(Integer)
    end
    
    test "submitted_time_tracked_minutes returns integer" do
      assert @task.time_tracked_minutes.kind_of?(Integer)
    end

    test "time_tracked method" do
      assert @task.respond_to?(:time_tracked)
    end

    test "time_tracked returns integer" do
      assert @task.time_tracked.kind_of?(Integer)
    end

    test "time_tracked_as_string method" do
      assert @task.respond_to?(:time_tracked_as_string)
    end

    test "time_tracked_as_string returns a string" do
      assert @task.time_tracked_as_string.kind_of?(String)
    end

    test "time_this_month method" do
      assert @task.respond_to?(:time_this_month)
    end
 
    test "time_this_month returns integer" do
      assert @task.time_this_month.kind_of?(Integer)
    end

    test 'should generate email if not related with quote' do
      assert_difference 'ActionMailer::Base.deliveries.size', +1 do
        create(:task, :not_quoted)
      end
    end

    test 'should not generate email if not related with quote' do
      assert_difference 'ActionMailer::Base.deliveries.size', 0 do
        create(:task, :quoted)
      end
    end

    test 'should not generate email if related to common tasks' do
      assert_difference 'ActionMailer::Base.deliveries.size', 0 do
        account = create(:account)
        project = account.projects.first
        task = create(:task, :not_quoted, project: project)
      end
    end
   
end
