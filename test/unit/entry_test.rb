require 'test_helper'
require 'icalendar'
include Icalendar

class EntryTest < ActiveSupport::TestCase

  test '#create_bulk should create one entry when no split requested' do
    assert_difference 'Entry.all.length', +1 do
      accounts(:accounts_001).entries.create_bulk({ start_date: Date.today, end_date: Date.today + 8, project_id: 1, user_id: 1 }, example_working_days, false)
    end
  end

  test '#create_bulk should return array when no split requested' do
    entries = accounts(:accounts_001).entries.create_bulk({ start_date: '2014-01-13', end_date: '2014-01-23', project_id: 1, user_id: 1 }, example_working_days, false)

    assert_kind_of Array, entries
  end

  test '#create_bulk should create two entries when split is requested' do
    assert_difference 'Entry.all.length', +2 do
      accounts(:accounts_001).entries.create_bulk({ start_date: '2014-01-13', end_date: '2014-01-23', project_id: 1, user_id: 1 }, example_working_days, true)
    end
  end

  test '#create_bulk should return array when split requested' do
    entries = accounts(:accounts_001).entries.create_bulk({ start_date: '2014-01-13', end_date: '2014-01-23', project_id: 1, user_id: 1 }, example_working_days, true)

    assert_kind_of Array, entries
  end

  test 'should return entries in the future' do
    project = create(:project)
    create(:entry, :future, project: project, account: project.account, user: project.account.users.first)
    create(:entry, :present, project: project, account: project.account, user: project.account.users.first)
    create(:entry, :past, project: project, account: project.account, user: project.account.users.first)

    assert_equal 2, Entry.ending_in_the_future.size
  end

	test "should create entry" do
		assert_difference 'Entry.all.length', +1 do
			accounts(:accounts_001).entries.create(valid_new_entry_params)
		end
	end

	test "should create entry with no end date" do
		assert_difference 'Entry.all.length', +1 do
			entry = accounts(:accounts_001).entries.create(valid_new_entry_params.merge(:end_date => nil))
			assert_equal entry.start_date, entry.end_date
		end
	end


	test "Should edit entry" do
		assert_no_difference 'Entry.all.length' do
			entries(:entries_001).update_attributes(:user_id => entries(:entries_001).account.users.first.id)
		end
	end


	test "should check end date is >= the start date" do
		assert_no_difference 'Entry.all.length' do
			accounts(:accounts_001).entries.create(valid_new_entry_params.merge(:end_date => Time.now.to_date - 1.day))
		end
	end


	test "should check all relations belong to the same account" do
		account = accounts(:accounts_001).entries.create(valid_new_entry_params.merge(:user_id => accounts(:accounts_002).users.first.id, :project_id => projects(:projects_007).id))
		assert account.errors[:user_id].present?
		assert account.errors[:project_id].present?
	end


	test "should check start date is required" do
		account = accounts(:accounts_001).entries.create( valid_new_entry_params.merge(:start_date => nil))
		assert account.errors[:start_date].present?
	end


	test "should check user id is required" do
		account = accounts(:accounts_001).entries.create( valid_new_entry_params.merge(:user_id => nil))
		assert account.errors[:user_id].present?
	end


	test "should check start project id is required" do
		account = accounts(:accounts_001).entries.create(valid_new_entry_params.merge(:project_id => nil))
		assert account.errors[:project_id].present?
	end


	test "should find all entries for a user between two dates for user" do
		start_date = Time.new(2012,5,24).to_date
		end_date = start_date + 20.days
		entries = Entry.for_user_period(accounts(:accounts_001).users.first.id, start_date, end_date)
		assert_not_nil entries
	end


	test "should find all entries in date hash for a user between two dates for user" do
		start_date = Time.new(2012,5,24).to_date
		end_date = start_date + 4.days
		entries = Entry.user_entries_by_date(accounts(:accounts_001).users.first.id, start_date, end_date)
		assert_equal Hash, entries.class
		assert_not_nil entries
	end


	test "should find all entries for an account between two dates" do
		start_date = Time.new(2012,5,24).to_date
		end_date = start_date + 20.days
		entries = Entry.for_period(accounts(:accounts_001).id, start_date, end_date)
		assert_not_nil entries
	end


	test "should find all entries for a project between two dates" do
		start_date = Time.new(2012,5,24).to_date
		end_date = start_date + 20.days
		entries = Entry.for_project_period(accounts(:accounts_001).projects.first.id, start_date, end_date)
		entries.each do |entry|
		    assert_equal accounts(:accounts_001).projects.first.id, entry.project_id 
	    end
		assert_not_nil entries
	end


	test "Should return the number of days an entry spans over" do
		entry = accounts(:accounts_001).entries.create(valid_new_entry_params)
		assert_equal 2, entry.number_of_days
	end


	test "Should return the number of days left for an entry" do
		entry = accounts(:accounts_001).entries.create(valid_new_entry_params)
		assert_equal 2, entry.number_of_days_left
	end


  test "should take a project_name and match it with an exisitng project and set the project id" do
        entry = accounts(:accounts_001).entries.new(valid_new_entry_params.merge(:project_id => nil, :project_name => accounts(:accounts_001).projects.last.name) )
        assert_nil entry.project_id
        assert_no_difference 'Project.all.length' do
            entry.save
        end
        assert_equal accounts(:accounts_001).projects.last.id, entry.project_id
    end


    test "should take a project_name and not match it with an exisitng project, but create a new one" do
        entry = accounts(:accounts_001).entries.new(valid_new_entry_params.merge(:project_id => nil, :project_name => accounts(:accounts_002).projects.first.name) )
        assert_nil entry.project_id
        assert_difference 'Project.all.length', +1 do
            entry.save
        end
        assert_not_equal accounts(:accounts_002).projects.first.id, entry.project_id
    end


    test "should check errors from new project prevent an event from being created" do
        entry = accounts(:accounts_001).entries.new(valid_new_entry_params.merge(:project_id => nil, :project_name => 256.times.collect { "a" }.join ))
        assert_nil entry.project_id
        assert_no_difference 'Project.all.length' do
            assert_no_difference 'Entry.all.length' do
                entry.save
            end
        end
        assert entry.new_record?
        assert entry.project.new_record?
    end


    test "users find all users for a given project" do
        users = Entry.users_for_project(accounts(:accounts_001).projects.first.id)
        users.each do |user|
		   assert_equal User, user.class 
	    end
		assert_not_nil users
    end
    
    
    # METHOD NOT USED
    # 
    # #
    # #
    # test "should find users who are free for a given day for an account" do
    #     calendar_date = Time.new(2012,5,24).to_date
    #     free_users = Entry.users_free_for(accounts(:accounts_001), calendar_date, {})
    #     free_users.each do |user|
    #          assert_equal 0, Entry.where(['entries.user_id = ? AND entries.start_date <= ? AND entries.end_date >= ?', user.id, calendar_date, calendar_date]).length
    #       end
    # end


    test "should get lead time for all users in an account" do
        lead_time_users =  Entry.user_lead_times(accounts(:accounts_001), {})
        assert_not_nil lead_time_users
    end


    test "should get lead time for 1 user in an account" do
        lead_time_users =  Entry.user_lead_times(accounts(:accounts_001), {:user_id => accounts(:accounts_001).users.first.id})
        assert_not_nil lead_time_users
        lead_time_users.each_with_index do |free_slot, index|
            assert_equal accounts(:accounts_001).users.first.id, free_slot[1][:user].id
        end
    end


    test "should get all userse scheudled for a project in a given period" do
        users = Entry.users_for_project_in_period(entries(:entries_001).project_id, entries(:entries_001).start_date, entries(:entries_001).start_date + 10.days)
        assert_not_nil users
    end
    
    
    test "should find number of days project is scheduled for between two entries" do
  		start_date = Time.new(2012,5,24).to_date
  		end_date = start_date + 20.days
  		number_of_days = Entry.get_number_of_days_scheduled_for_project_by_period(projects(:projects_001), start_date, end_date)
      assert_equal 15, number_of_days
  	end

    test '#to_ics should return an Icalendar Event object' do
      entry = entries(:entries_001)
      assert_equal Icalendar::Event, entry.to_ics.class
    end

    test '#to_ics should return an Icalendar Event object with the correct title' do
      entry = entries(:entries_001)
      assert_equal 'No client or team project', entry.to_ics.summary
    end

    test '#to_ics should return a start_date that coinsides with the working times of the Account' do
      entry = entries(:entries_001)
      assert_equal '20120518T090000', entry.to_ics.start
    end

    test '#to_ics should return an end_date that coinsides with the working times of the Account' do
      entry = entries(:entries_001)
      assert_equal '20120524T170000', entry.to_ics.end
    end

    test '#to_ics should return a helpful description field' do
      entry = entries(:entries_001)
      expected_description = 'Project: No client or team project - Client: BBC'
      assert_equal expected_description, entry.to_ics.description
    end

protected


	def valid_new_entry_params
		{:start_date => Time.now.to_date, :end_date => (Time.now.to_date + 1.day), :user_id => accounts(:accounts_001).users.first.id, :project_id => accounts(:accounts_001).projects.first.id}
	end
	
  def example_working_days
    { monday: '1', tuesday: '1', wednesday: '1', thursday: '1', friday: '1', saturday: '0', sunday: '1' }
  end
	
end
