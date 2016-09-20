class AddStartAtToTheme < ActiveRecord::Migration
  def change
    add_column :themes, :start_at, :datetime
  end
end
