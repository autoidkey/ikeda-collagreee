class CreateTaggedEntries < ActiveRecord::Migration
  def change
    create_table :tagged_entries do |t|
      t.integer :entry_id, null: false
      t.integer :issue_id, null: false

      t.timestamps
    end
  end
end
