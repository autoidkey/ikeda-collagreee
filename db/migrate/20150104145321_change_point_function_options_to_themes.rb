class ChangePointFunctionOptionsToThemes < ActiveRecord::Migration
  def up
    change_column :themes, :point_function, :boolean, default: true
  end

  def down
    change_column :themes, :point_function, :boolean, null: false, default: ''
  end
end
