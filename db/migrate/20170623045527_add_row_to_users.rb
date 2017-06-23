class AddRowToUsers < ActiveRecord::Migration
  def change
    add_column :users, :row, :integer
  end
end
