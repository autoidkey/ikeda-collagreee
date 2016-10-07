class AddThemeIdToVoteEntries < ActiveRecord::Migration
  def change
    add_column :vote_entries, :theme_id, :integer
  end
end
