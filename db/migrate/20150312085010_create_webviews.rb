class CreateWebviews < ActiveRecord::Migration
  def change
    create_table :webviews do |t|
      t.integer :user_id
      t.integer :theme_id

      t.timestamps
    end
    add_index :webviews, :user_id
    add_index :webviews, :theme_id
  end
end
