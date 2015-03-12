class AddIndexToEntryParentId < ActiveRecord::Migration
  def up
    change_column :entries, :parent_id, :integer, index: true
  end

  def down
    change_column :entries, :parent_id, :integer
  end
end
