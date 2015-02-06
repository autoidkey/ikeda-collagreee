class ChangeDatatypeMoveOfUsers < ActiveRecord::Migration
  def up
    change_column :users, :move, :integer, default: 0
  end

  def down
    change_column :users, :move, :integer, null: false, default: ''
  end
end
