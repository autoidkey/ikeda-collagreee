class AddThemeIdToPhase < ActiveRecord::Migration
  def change
    add_column :phases, :theme_id, :integer
  end
end
