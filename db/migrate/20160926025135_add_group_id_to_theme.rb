class AddGroupIdToTheme < ActiveRecord::Migration
  def change
    add_column :themes, :group_id, :integer
  end
end
