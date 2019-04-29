class AddProjectColorToProjects < ActiveRecord::Migration
    def change
        add_column :projects, :color, :string, :size => 6, :default => '#B7C18F'
        add_column :projects, :event_type, :integer, :default => 0
    end
end
