class ChangeDatatypeHomeOfUsers < ActiveRecord::Migration
  def up
    change_column :users, :home, :integer, default: 0
  end

  def down
    change_column :users, :home, :integer, null: false, default: ''
  end
end
