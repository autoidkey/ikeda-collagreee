class AddThemeIdToNotice < ActiveRecord::Migration
  def change
    add_column :notices, :theme_id, :integer
  end
end
