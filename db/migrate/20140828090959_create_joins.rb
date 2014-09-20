class CreateJoins < ActiveRecord::Migration
  def change
    create_table :joins do |t|
      t.integer :theme_id, null: false
      t.integer :user_id, null: false

      t.timestamps
    end
  end
end
