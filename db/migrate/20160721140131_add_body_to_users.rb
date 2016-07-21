class AddBodyToUsers < ActiveRecord::Migration
  def change
    add_column :users, :body, :text
  end
end
