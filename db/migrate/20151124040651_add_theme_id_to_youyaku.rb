class AddThemeIdToYouyaku < ActiveRecord::Migration
  def change
    add_column :youyakus, :theme_id, :integer
  end
end
