class AddIndexToEntries < ActiveRecord::Migration
  def change
    add_index :entries, :parent_id
  end
end
