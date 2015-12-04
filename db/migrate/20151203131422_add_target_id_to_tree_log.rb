class AddTargetIdToTreeLog < ActiveRecord::Migration
  def change
    add_column :tree_logs, :targer_id, :integer
  end
end
