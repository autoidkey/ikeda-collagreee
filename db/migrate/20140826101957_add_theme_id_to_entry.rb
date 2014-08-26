class AddThemeIdToEntry < ActiveRecord::Migration
  def change
    add_column :entries, :theme_id, :integer
  end
end
