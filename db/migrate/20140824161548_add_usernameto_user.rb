class AddUsernametoUser < ActiveRecord::Migration
  def change
    add_column :users, :username, :string, null: false
    add_column :users, :realname, :string, null: false
    add_column :users, :role, :integer, default: 1
  end
end
