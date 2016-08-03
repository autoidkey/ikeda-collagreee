class CreateEntryClasters < ActiveRecord::Migration
  def change
    create_table :entry_clasters do |t|
      t.integer :entry_id
      t.integer :coaster

      t.timestamps
    end
  end
end
