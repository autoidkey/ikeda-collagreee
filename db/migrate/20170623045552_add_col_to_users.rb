class AddColToUsers < ActiveRecord::Migration
  def change
    add_column :users, :col, :integer
  end
end
