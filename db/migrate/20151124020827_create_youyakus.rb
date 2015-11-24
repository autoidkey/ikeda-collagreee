class CreateYouyakus < ActiveRecord::Migration
  def change
    create_table :youyakus do |t|
      t.string :body
      t.integer :target_id

      t.timestamps
    end
  end
end
