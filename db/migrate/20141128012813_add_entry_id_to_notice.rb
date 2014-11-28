class AddEntryIdToNotice < ActiveRecord::Migration
  def change
    add_column :notices, :entry_id, :integer
  end
end
