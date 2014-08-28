class AddContentToActivities < ActiveRecord::Migration
  def change
    remove_column :activities, :info
    change_column :activities, :read, :boolean
    change_column :activities, :atype, :integer

    add_column :activities, :theme_id, :integer
    add_column :activities, :entry_id, :integer
  end
end
