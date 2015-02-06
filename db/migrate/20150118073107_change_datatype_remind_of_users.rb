class ChangeDatatypeRemindOfUsers < ActiveRecord::Migration
  def up
    change_column :users, :remind, :integer, default: 0
  end

  def down
    change_column :users, :remind, :integer, null: false, default: ''
  end
end
