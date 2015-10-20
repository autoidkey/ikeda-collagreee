class CreateFacilitationInfomations < ActiveRecord::Migration
  def change
    create_table :facilitation_infomations do |t|
      t.text :body
      t.integer :theme_id

      t.timestamps
    end
  end
end
