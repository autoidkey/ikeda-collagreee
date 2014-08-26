class AddInfoToUsers < ActiveRecord::Migration
  def change
    remove_column :users, :username
    add_column :users, :name, :string, null: false
    add_column :users, :gender, :integer
    add_column :users, :age, :integer
    add_column :users, :home, :string
    add_column :users, :move, :string
    add_column :users, :remind, :boolean, default: true
    add_column :users, :mail_format, :integer, default: 0
  end
end
