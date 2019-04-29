require 'test_helper'

class ClientTest < ActiveSupport::TestCase

    test "should create new client" do
      assert_difference 'Client.all.length', +1 do
        accounts(:accounts_001).clients.create(:name => 'new client name')
      end
    end

    test "should not allow the same client name twice per account" do
      assert_difference 'Client.all.length', +1 do
        accounts(:accounts_001).clients.create(:name => 'new client name')
        accounts(:accounts_001).clients.create(:name => 'new client name')
      end
    end

    test "should get clients for account ordered by name" do 
      clients = accounts(:accounts_001).clients.name_ordered
      assert_not_nil clients
    end

    test "should remove whitespace on save" do
      client = accounts(:accounts_001).clients.create(:name => ' new client name ')
      assert_equal 'new client name', client.name
    end

    test "should find all active clients" do
      clients = Client.search(accounts(:accounts_001), {:archived => '0'})
      assert_not_nil clients
      for client in clients
        assert_equal false, client.archived
      end
    end

    test "should find all archived clients" do
      clients = Client.search(accounts(:accounts_001), {:archived => '1'})
      assert_not_nil clients
      for client in clients
        assert_equal true, client.archived
      end
    end

    test "should archive a client" do
      clients(:clients_001).archived = 0
      clients(:clients_001).save!
      
      clients(:clients_001).archive_now
      assert_equal true, clients(:clients_001).archived
    end

    test "should unarchive a client" do
      clients(:clients_003).archived = 1
      clients(:clients_003).save!
      
      clients(:clients_003).un_archive_now
      assert_equal false, clients(:clients_003).archived
    end

    test "should get all people scheudled for a given client" do
      users = clients(:clients_001).all_people_scheduled
      assert_not_nil users
      for user in users
        assert user.kind_of?(User)
      end
    end

    test "should get all people scheudled for a given client for the next week" do
      start_date = Time.new(2012,5,24).to_date
      users = clients(:clients_001).people_scheduled_for_next_week_from(start_date)
      users.each do |user|
        assert_equal User, user.class 
      end
      assert_not_nil users
    end

    test "should get all people tracked for a given client" do
      users = clients(:clients_001).all_people_tracked
      assert_not_nil users
      for user in users
        assert user.kind_of?(User)
      end
    end

    test "should get all people tracked for a given client in a given week" do
      start_date = Time.new(2012,5,24).to_date
      users = clients(:clients_001).people_tracked_for_a_week_from(start_date)
      assert_not_nil users
      for user in users
        assert user.kind_of?(User)
      end
    end

    test "should get the avarage day rate for the client" do
      assert_equal 76112, clients(:clients_001).avg_rate_card_amount_cents
      assert_equal 76992, clients(:clients_002).avg_rate_card_amount_cents
    end

    test '#internal? should return true if the client is internal' do
      client = clients(:clients_001)
      client.internal = true
      assert_equal true, client.internal?
    end

    test '#internal? should return false if the client is not internal' do
      client = clients(:clients_001)
      assert_equal false, client.internal?
    end

    test '#all_people_scheduled should return a list of Users scheduled on the Clients projects' do
      client = clients(:clients_001)
      assert_equal [users(:users_008), users(:users_005), users(:users_001)], client.all_people_scheduled
    end

end
