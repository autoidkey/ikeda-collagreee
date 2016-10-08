class AddTargetToVoteEntry < ActiveRecord::Migration
  def change
    add_column :vote_entries, :targer, :boolean
  end
end
