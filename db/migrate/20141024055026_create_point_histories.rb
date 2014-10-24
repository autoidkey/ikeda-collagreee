class CreatePointHistories < ActiveRecord::Migration
  def change
    create_table :point_histories do |t|
      t.integer :user_id
      t.integer :entry_id
      t.integer :theme_id
      t.integer :activity_id
      t.float :point
      t.integer :type
      t.integer :action
      t.integer :depth

      t.timestamps
    end
  end
end
