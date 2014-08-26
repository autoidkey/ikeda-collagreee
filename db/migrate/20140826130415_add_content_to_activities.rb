class AddContentToActivities < ActiveRecord::Migration
  def change
    remove_column :activities, :info
    change_column :activities, :read, :boolean

    add_column :activities, :theme_id, :integer
    add_column :activities, :entry_id, :integer
  end
end
