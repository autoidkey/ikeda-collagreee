class AddPointFunctionToTheme < ActiveRecord::Migration
  def change
    add_column :themes, :point_function, :boolean
  end
end
