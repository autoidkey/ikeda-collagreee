class ChangeDatatypeBodyOfEntries < ActiveRecord::Migration
  def up
    change_column :entries, :body, :text
  end

  def down
    change_column :entries, :body, :text, null: false
  end
end
