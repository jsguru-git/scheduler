require 'test_helper'

class ProjectTest < ActiveSupport::TestCase

    test "stale_opportunities scope should return all projects with opportunity status not updated for 2 weeks" do
      10.times { create(:stale_opportunity) }
      8.times { create(:not_stale_opportunity) }
      assert_equal 10, Project.stale_opportunities.count
    end

    test "should create new proejct" do
        assert_difference 'Project.all.length', +1 do
            accounts(:accounts_001).projects.create(:name => 'new team name')
        end
    end


    test "should check default archived status" do
        project = accounts(:accounts_001).projects.create(:name => 'new team name')
        assert_equal false, project.archived
    end


    test "should edit project" do
        assert_no_difference 'Project.all.length' do
            projects(:projects_001).update_attributes(:name => 'new team name', :percentage_complete => 50)
        end
    end


    test "should remove whitespace on create" do
        project = accounts(:accounts_001).projects.create(:name => 'new team name')
        assert_equal 'new team name', project.name
    end


    test "should search projects" do
        account = accounts(:accounts_001)
        projects = Project.search(account, {})
        assert_not_nil projects
        for project in projects
            assert_equal accounts(:accounts_001).id, project.account_id
        end
    end

    test "search should not fail if json request with no params" do
      account = accounts(:accounts_001)
      assert_nothing_raised do 
        Project.search(account, {format: 'json'})
      end
    end

    test '#search with open status should not find closed projects' do
      account = accounts(:accounts_001)
      project = account.projects.first
      project.override_status(:closed)

      assert_false Project.search(account, { format: 'json', status: 'open' }).include?(project)
    end


    test "cant save client from different account" do
        client = accounts(:accounts_002).clients.create!(:name => 'new client')

        client_new = accounts(:accounts_001).projects.create(:name => 'test another name', :client_id => client.id)
        assert client_new.new_record?
        assert client_new.errors[:client_id].present?
    end
    
    
    test "cant save team from different account" do
        team = accounts(:accounts_002).teams.create!(:name => 'new client')

        team_new = accounts(:accounts_001).projects.create(:name => 'test another name', :team_id => team.id)
        assert team_new.new_record?
        assert team_new.errors[:team_id].present?
    end
    
    
    test "cant save business owner from different account" do
        user = users(:users_002)

        business_owner_new = accounts(:accounts_001).projects.create(:name => 'test another name', :business_owner_id => user.id)
        assert business_owner_new.new_record?
        assert business_owner_new.errors[:business_owner_id].present?
    end


    test "create default projects" do
        assert_difference 'Project.all.length', +1 do
            assert_difference 'Task.all.length', +5 do
                Project.create_default_internal_projects(accounts(:accounts_001))
            end
        end
    end
    

    test "should check only valid color codes are saved" do
        account = accounts(:accounts_001)
        
        project = account.projects.first
        assert project.save
        
        project.color = 'FFFFFF'
        assert_equal false, project.save
        
        project.color = 'FFFFFasdfF'
        assert_equal false, project.save
        
        project.color = '#FFFFFF'
        assert project.save
    end


    test "should find people scheduled for next 7 days" do
        start_date = Time.new(2012,5,24).to_date
        users = accounts(:accounts_001).projects.first.people_scheduled_for_next_week_from(start_date)
        users.each do |user|
		   assert_equal User, user.class 
	    end
		assert_not_nil users
    end


    test "should find all people scheduled on project" do
        users = accounts(:accounts_001).projects.first.all_people_scheduled
        users.each do |user|
		   assert_equal User, user.class 
	    end
		assert_not_nil users
    end


    test "should archive a project" do
        project = accounts(:accounts_001).projects.first
        project.archive_now
        assert_equal true, project.archived
    end


    test "should re activate a project" do
        project = accounts(:accounts_001).projects.first
        project.archive_now
        project.un_archive_now
        assert_equal false, project.archived
    end


    test "should remove project but fail if has associated timings" do
        assert_no_difference 'Project.all.size' do
            project = Project.find(projects(:projects_002).id)
            
            assert_raise ActiveRecord::DeleteRestrictionError do
                project.destroy
            end
            
        end
    end


    test "should remove project that has no timings" do
        assert_difference 'Project.all.size', -1 do
            project = Project.find(projects(:projects_001).id)
            project.destroy
        end
    end
    

    test "should get the scheulded start date for a project" do
        start_date = projects(:projects_002).schedule_start_date
        assert start_date.kind_of?(Date), 'Should be a date returned if entries exist'
    end


    test "should get total estimate for a given project" do
        estimate_mins = projects(:projects_002).total_estimate
        assert estimate_mins.kind_of?(Integer)
    end

    test "should get total tracked for a given project" do
        estimate_mins = projects(:projects_002).total_tracked
        assert estimate_mins.kind_of?(Integer)
    end

    test "should get all people tracked to a project" do
        users = projects(:projects_002).all_people_tracked
        assert_not_nil users
        for user in users
            assert user.kind_of?(User)
        end
    end


    test "should get all people tracked to a project for a given week" do
        start_date = Time.new(2012,5,10).to_date
        users = projects(:projects_002).people_tracked_for_a_week_from(start_date)
        assert_not_nil users
        for user in users
            assert estimate_mins.kind_of?(User)
        end
    end


    test "project should have an optional project code" do
        project = Project.new
        assert_respond_to project, :project_code
    end


    test "has_tasks? should return false for projects with no tasks" do
      project = projects(:projects_001)
      assert_equal false, project.has_tasks?
    end


    test "has_tasks? should return true for projects with tasks" do
      project = projects(:projects_002)
      assert_equal true, project.has_tasks?
    end
    
    
    test "should get payment predication results" do
      results = Project.payment_prediction_results(accounts(:accounts_001), {}, Date.parse('2013-03-01'), Date.parse('2013-03-31'))
      assert_equal 250000, results[2][:expected]
      assert_equal 74000, results[2][:requested]
    end
    
    
    test "should get payment prediction totals" do
      totals = Project.payment_prediction_totals(accounts(:accounts_001), {}, Date.parse('2013-03-01'), Date.parse('2013-03-31'))
      assert_equal 250000, totals[:current_year][:expected]
      assert_equal 148000, totals[:current_year][:requested]
      assert_equal totals[:current_year][:requested] + totals[:current_year][:expected] + totals[:last_year][:sent], totals[:current_year][:total]
      
      assert_equal 0, totals[:last_year][:expected]
      assert_equal 0, totals[:last_year][:requested]
      assert_equal totals[:last_year][:requested] + totals[:last_year][:expected] + totals[:last_year][:sent], totals[:last_year][:total]
      assert_equal 74000, totals[:current_year][:pre_payment_total]
    end
    
    
    test "should get associated team" do
      assert_not_nil projects(:projects_001).team
      assert_equal teams(:teams_001).id, projects(:projects_001).team.id
    end
    
    
    test "should get associated business owner" do
      assert_not_nil projects(:projects_001).business_owner
      assert_equal users(:users_001).id, projects(:projects_001).business_owner.id
    end
    
    
    test "should get associated project manager" do
      assert_not_nil projects(:projects_001).project_manager
      assert_equal users(:users_001).id, projects(:projects_001).project_manager.id
    end
    
    
    test "should get number of projects that expect a payment for a given time period" do
      start_date = Date.parse '2013-03-10'
      end_date = Date.parse '2013-03-30'
      number = Project.number_with_payment_expected_for_period(accounts(:accounts_001), start_date, end_date)
      assert_equal 2, number
    end
    
    
    test "should get number of projects with payments expected which have an invoice" do
      start_date = Date.parse '2013-03-10'
      end_date = Date.parse '2013-03-30'
      number = Project.number_with_payment_expected_for_period_with_raised_invoice(accounts(:accounts_001), start_date, end_date)
      assert_equal 2, number
    end
    
    test "should get the total project cost" do
      assert_equal 460000, projects(:projects_002).total_project_cost_cents
    end
    
    test "should get the total project cost which has not been invoiced" do
      assert_equal 250000, projects(:projects_002).total_project_cost_cents_not_invoiced
    end
    
    test "should get the total project cost which has been invoiced" do
      assert_equal 210000, projects(:projects_002).total_project_cost_cents_invoiced
    end

    # Project Status

    test 'Should be able to override #project_status' do
      project = Project.create
      project.override_status('in_progress')
      project.save

      assert_equal 'in_progress', project.project_status
    end

    test 'New Project should have status of opportunity' do
      project = Project.create

      assert_equal 'opportunity', project.project_status
    end

    test 'Project with one or more accepted quotes should be approved' do
      project = projects(:projects_001)
      project.timings = []
      project.entries = []
      project.save

      quote = project.quotes.first
      quote.quote_status = 2
      quote.save

      assert_equal 'approved', project.reload.project_status
    end

    test 'Project with a schedule should be scheduled' do
      project = projects(:projects_001)
      project.timings = []
      project.entries = []
      project.entries.build({ start_date: Time.now, end_date: 1.day.from_now })
      project.save

      assert_equal 'scheduled', project.project_status
    end
    
    test 'Project being tracked should be in_progress' do
      project = projects(:projects_001)
      project.timings = []
      project.timings.build({ started_at: Time.now, ended_at: 1.day.ago, task_id: 1 })
      project.save

      assert_equal 'in_progress', project.project_status
    end

    test 'Project fully paid should be closed' do
      project = projects(:projects_002)
      pp = project.payment_profiles.all.take(2)
      project.payment_profiles = pp
      project.invoices.each { |i| i.update_attribute(:invoice_status, 2) }
      project.save
    
      assert_equal 'closed', project.project_status
    end
    
    test 'should send project budget emails and update last_budget_check' do
      Project.send_project_budget_email
      
      assert_equal 7.59, projects(:projects_002).last_budget_check, projects(:projects_002).last_budget_check.to_s
    end
    
    
    test 'should send emails only once per budget reached' do
      user = accounts(:accounts_001).users.first
      timing = user.timings.create!(:started_at => '2013-05-15 08:00:00', :ended_at => '2013-05-15 20:29:00', :project_id => projects(:projects_002).id, :task_id => projects(:projects_002).tasks.first.id) 
      timing.submitted = true
      timing.save!
      
      assert_difference 'ActionMailer::Base.deliveries.size', +1 do  
        Project.send_project_budget_email
      end
      
      assert_no_difference 'ActionMailer::Base.deliveries.size' do  
        Project.send_project_budget_email
      end
    end

    test '#estimated_end_date should percentage complete projection' do
      account = create(:account)
      user = account.users.first
      project = create(:project, account: account)
      task = create(:task, project: project)
      timing = create(:timing, started_at: 2.days.ago.change(hour: 9), ended_at: 2.days.ago.change(hour: 16, min: 29), submitted: true, user: user, project: project, task: task)
      Project.any_instance.stubs(:percentage_complete).returns(50)

      assert_equal 2.days.from_now.to_date, project.estimated_end_date
    end

    test '#estimated_end_date should return nil if no timings data' do
      account = create(:account)
      user = account.users.first
      project = create(:project, account: account)
      Project.any_instance.stubs(:percentage_complete).returns(50)

      assert_nil project.estimated_end_date
    end

    test '#estimated_end_date should return nil if percentage complete is 0' do
      account = create(:account)
      user = account.users.first
      project = create(:project, account: account)
      task = create(:task, project: project)
      timing = create(:timing, started_at: 2.days.ago.change(hour: 9), ended_at: 2.days.ago.change(hour: 16, min: 29), submitted: true, user: user, project: project, task: task)
      Project.any_instance.stubs(:percentage_complete).returns(0)

      assert_nil project.estimated_end_date
    end
    
    test '#estimated_end_date should return nil if percentage complete is 100' do
      account = create(:account)
      user = account.users.first
      project = create(:project, account: account)
      task = create(:task, project: project)
      timing = create(:timing, started_at: 2.days.ago.change(hour: 9), ended_at: 2.days.ago.change(hour: 16, min: 29), submitted: true, user: user, project: project, task: task)
      Project.any_instance.stubs(:percentage_complete).returns(100)

      assert_nil project.estimated_end_date
    end
end
