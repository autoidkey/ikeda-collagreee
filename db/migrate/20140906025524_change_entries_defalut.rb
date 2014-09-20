class ChangeEntriesDefalut < ActiveRecord::Migration
  def change
    change_column :entries, :invisible, :boolean, default: false
    change_column :entries, :top_fix, :boolean, default: false
    change_column :entries, :facilitation, :boolean, default: false
    change_column :entries, :np, :integer, default: 0
  end
end
