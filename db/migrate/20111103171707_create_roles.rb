class CreateRoles < ActiveRecord::Migration
    def change
        create_table "roles", :force => true do |t|
            t.column "title", :string
        end
        create_table "roles_users", :id => false, :force => true do |t|
            t.column "role_id", :integer
            t.column "user_id", :integer
        end

        add_index :roles_users, :role_id
		add_index :roles_users, :user_id
    end
end
