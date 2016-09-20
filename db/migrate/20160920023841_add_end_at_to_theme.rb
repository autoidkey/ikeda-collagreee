class AddEndAtToTheme < ActiveRecord::Migration
  def change
    add_column :themes, :end_at, :datetime
  end
end
