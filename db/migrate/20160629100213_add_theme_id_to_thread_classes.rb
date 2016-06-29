class AddThemeIdToThreadClasses < ActiveRecord::Migration
  def change
    add_column :thread_classes, :theme_id, :integer
  end
end
