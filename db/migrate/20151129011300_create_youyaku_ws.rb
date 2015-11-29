class CreateYouyakuWs < ActiveRecord::Migration
  def change
    create_table :youyaku_ws do |t|
      t.integer :target_id
      t.integer :thread_id
      t.integer :theme_id

      t.timestamps
    end
  end
end
