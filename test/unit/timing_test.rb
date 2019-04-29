require 'test_helper'

class TimingTest < ActiveSupport::TestCase

    test "should create a new timing" do
        assert_difference 'Timing.all.size', +1 do
            user = accounts(:accounts_001).users.first
            timing = user.timings.create(:started_at => '2012-05-15 08:00:00', :ended_at => '2012-05-15 09:29:00', :project_id => accounts(:accounts_001).projects.first.id, :task_id => accounts(:accounts_001).projects.first.tasks.first.id) 
            assert_equal false, timing.submitted?
        end
    end
    
    test "should create a new timing that is automatiically marked as submitted as others on that day have already been" do
        user = accounts(:accounts_001).users.first
        timing1 = user.timings.create(:started_at => '2012-05-15 08:00:00', :ended_at => '2012-05-15 09:29:00', :project_id => accounts(:accounts_001).projects.first.id, :task_id => accounts(:accounts_001).projects.first.tasks.first.id) 
        timing1.submitted = true
        timing1.save
        
        timing2 = user.timings.create(:started_at => '2012-05-15 10:00:00', :ended_at => '2012-05-15 11:29:00', :project_id => accounts(:accounts_001).projects.first.id, :task_id => accounts(:accounts_001).projects.first.tasks.first.id) 
        assert timing2.submitted?
    end

    test "should create a new timing but fail due to no start date" do
        assert_no_difference 'Timing.all.size' do
            user = accounts(:accounts_001).users.first
            timing = user.timings.create(:started_at => '', :ended_at => '2012-05-15 09:29:00', :project_id => accounts(:accounts_001).projects.first.id, :task_id => accounts(:accounts_001).projects.first.tasks.first.id)
            assert timing.errors[:started_at].present?
        end
    end

    test "should create a new timing but fail as start date is greater than end" do
        assert_no_difference 'Timing.all.size' do
            user = accounts(:accounts_001).users.first
            timing = user.timings.create(:started_at => '2012-05-15 11:30:00', :ended_at => '2012-05-15 09:29:00', :project_id => accounts(:accounts_001).projects.first.id, :task_id => accounts(:accounts_001).projects.first.tasks.first.id) 
            assert timing.errors[:started_at].present?
        end
    end

    test "should calculate duration in minutes on save" do
        user = accounts(:accounts_001).users.first
        timing = user.timings.create(:started_at => '2012-05-15 08:30:00', :ended_at => '2012-05-15 09:44:00', :project_id => accounts(:accounts_001).projects.first.id, :task_id => accounts(:accounts_001).projects.first.tasks.first.id)
        assert_equal 75, timing.duration_minutes
    end

    test "should create a new timing but fail due to not starting and ending on the same day" do
        assert_no_difference 'Timing.all.size' do
            user = accounts(:accounts_001).users.first
            timing = user.timings.create(:started_at => '2012-05-15 08:30:00', :ended_at => '2012-05-16 08:59:00', :project_id => accounts(:accounts_001).projects.first.id, :task_id => accounts(:accounts_001).projects.first.tasks.first.id)
            assert timing.errors[:started_at].present?
        end
    end

    test "should create a new timing but fail due to another entry existing on that time already" do
        assert_no_difference 'Timing.all.size' do
            user = User.find(1)
            
            timing = user.timings.create(:started_at => '2012-05-10 07:00:00', :ended_at => '2012-05-10 08:59:00', :project_id => accounts(:accounts_001).projects.first.id, :task_id => accounts(:accounts_001).projects.first.tasks.first.id)
            assert timing.errors[:started_at].present?
        end
    end

    test "should find timings for a given period" do
        timings = Timing.for_period(1, Date.parse('2012-05-10'), Date.parse('2012-05-10'))
        assert_not_nil timings
    end

    test "should find timings for a given period of time" do
        timings = Timing.for_period_of_time(1, DateTime.parse('2012-05-10 08:00:00'), DateTime.parse('2012-05-10 09:00:00'))
        assert_not_nil timings
    end

    test "should not allow tasks and users from different accounts to be assocaited" do
        assert_no_difference 'Timing.all.size' do
            user = accounts(:accounts_001).users.first
            timing = user.timings.create(:started_at => '2012-05-15 08:00:00', :ended_at => '2012-05-15 09:34:00', :project_id => accounts(:accounts_001).projects.first.id, :task_id => tasks(:tasks_008).id) 
            assert timing.errors[:task_id].present?
        end
    end

    test "should not allow project and users from different accounts to be assocaited" do
        assert_no_difference 'Timing.all.size' do
            user = accounts(:accounts_001).users.first
            timing = user.timings.create(:started_at => '2012-05-15 08:00:00', :ended_at => '2012-05-15 09:29:00', :project_id => accounts(:accounts_002).projects.first.id, :task_id => accounts(:accounts_001).projects.first.tasks.first.id)
            assert timing.errors[:project_id].present?
        end
    end

    test "should not force task id when not submitted" do
        assert_difference 'Timing.all.size', +1 do
            user = accounts(:accounts_001).users.first
            user.timings.create(:started_at => '2012-05-15 08:00:00', :ended_at => '2012-05-15 09:29:00', :project_id => accounts(:accounts_001).projects.first.id) 
        end
    end

    test "should force task id when submitted" do
        assert_no_difference 'Timing.all.size' do
            user = accounts(:accounts_001).users.first
            timing = user.timings.new(:started_at => '2012-05-15 08:00:00', :ended_at => '2012-05-15 09:29:00', :project_id => accounts(:accounts_001).projects.first.id) 
            timing.submitted = true
            timing.save
            assert timing.errors[:task_id].present?
        end
    end

    test "should submit time entries for a given day" do
        submitted = Timing.submit_entries_for_user_and_day(timings(:one).user_id, timings(:one).started_at.to_date)
        timings(:one).reload
        assert timings(:one).submitted?
        assert_equal false, timings(:three).submitted?
    end

    test "should submit time entries for a given day but fail as there are no entries" do
        submitted = Timing.submit_entries_for_user_and_day(timings(:one).user_id, timings(:one).started_at.to_date + 50.days)
        assert_equal 2, submitted
    end

    test "should find all users that have tracked time for a particular project" do
        users = Timing.users_for_project(timings(:one).project_id)
        assert_not_nil users
    end

    test "should find all users that have tracked time for a particular project within a given date range" do
      start_date = Time.new(2012,5,10).to_date
	    end_date = start_date + 6.days
      users = Timing.users_for_project_in_period(timings(:one).project_id, start_date, end_date)
      assert_not_nil users
    end
    
    
    test "should get the projects for a client in a given period" do
      start_date = Time.new(2012,5,10).to_date
	    end_date = start_date + 6.days
      projects = Timing.projects_for_client_in_period(timings(:one).project.client_id, start_date, end_date)
      assert_not_nil projects
    end
    
    
    test "should get all times for a given date range for a given project" do
      start_date = Time.new(2012,7,10).to_date
	    end_date = start_date + 6.days
	    projects = Timing.submitted_for_period_by_project(timings(:five).project_id, start_date, end_date)
	    assert_not_nil projects
    end
    
    
    test "should get number of minutes tracked between a date period for a given project" do
      start_date = Time.new(2012,7,10).to_date
	    end_date = start_date + 6.days
	    mins = Timing.minute_duration_submitted_for_period_by_project(timings(:five).project_id, start_date, end_date)
	    assert_equal 60, mins
    end
    
    
    test "should get duration for a given date range for a given client" do
      start_date = Time.new(2012,7,10).to_date
	    end_date = start_date + 6.days
	    min_duration = Timing.minute_duration_submitted_for_period_and_client(timings(:five).project.client_id, start_date, end_date)
	    assert_equal 60, min_duration
    end
    
    
    test "should get duration for a given client" do
	    min_duration = Timing.minute_duration_submitted_for_client(timings(:five).project.client_id)
	    assert_equal 60, min_duration
    end
    
    
    test "should get duration for a given date range for a given team" do
      start_date = Time.new(2012,7,10).to_date
	    end_date = start_date + 6.days
	    min_duration = Timing.minute_duration_submitted_for_period_and_team(timings(:five).user.teams.first.id, start_date, end_date)
	    assert_equal 60, min_duration
    end
    
    
    test "should get duration for a given date range for a given team and project" do
      start_date = Time.new(2012,7,10).to_date
	    end_date = start_date + 6.days
	    min_duration = Timing.minute_duration_submitted_for_period_and_team_and_project(timings(:five).user.teams.first.id, timings(:five).project_id, start_date, end_date)
	    assert_equal 60, min_duration
    end

    test '#check_within_estimate should send email if timing causes over estimate' do
      account = create(:account)
      project = create(:project, account: account)
      task = create(:task, estimated_minutes: 50, project: project)
      timing = create(:timing, started_at: 1.day.ago.change(hour: 9, min: 0), ended_at: 1.day.ago.change(hour: 10, min: 00), task: task, project: project, user: account.users.first)
      assert_difference 'ActionMailer::Base.deliveries.size', +1 do
        timing.update_attribute(:submitted, true)
      end
    end

    test '#check_within_estimate should not send email if already over estimate' do
      account = create(:account)
      project = create(:project, account: account)
      task = create(:task, estimated_minutes: 50, project: project)
      create(:timing, started_at: 1.day.ago.change(hour: 9, min: 0), ended_at: 1.day.ago.change(hour: 10, min: 0), submitted: true, task: task, project: project, user: account.users.first)
      timing = create(:timing, started_at: 1.day.ago.change(hour: 11, min: 0), ended_at: 1.day.ago.change(hour: 12, min: 0), task: task, project: project, user: account.users.first)
      assert_no_difference 'ActionMailer::Base.deliveries.size' do
        timing.update_attribute(:submitted, true)
      end
    end
       
    test '#check_within_estimate should not send email if under estmate' do
      account = create(:account)
      project = create(:project, account: account)
      task = create(:task, estimated_minutes: 50, project: project)
      timing = create(:timing, started_at: 1.day.ago.change(hour: 9, min: 0), ended_at: 1.day.ago.change(hour: 9, min: 30), task: task, project: project, user: account.users.first)
      assert_no_difference 'ActionMailer::Base.deliveries.size' do
        timing.update_attribute(:submitted, true)
      end
    end
end
