class CreateTweets < ActiveRecord::Migration
    def change
        create_table "tweets" do |t|
            t.integer "tweet_id_ref", :limit => 8
            t.string "title"
            t.string "user_name"
            t.datetime "published_at"
            t.boolean "active", :default => true
            t.datetime "created_at"
            t.datetime "updated_at"
            t.integer "top_priority"
        end
    end
end
