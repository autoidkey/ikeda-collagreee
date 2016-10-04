class CreateVoteEntries < ActiveRecord::Migration
  def change
    create_table :vote_entries do |t|
      t.integer :user_id
      t.integer :entry_id
      t.integer :point

      t.timestamps
    end
  end
end
