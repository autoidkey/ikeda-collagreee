class CreateTreedata < ActiveRecord::Migration
  def change
    create_table :treedata do |t|
      t.integer :user_id
      t.integer :theme_id

      t.timestamps
    end
  end
end
