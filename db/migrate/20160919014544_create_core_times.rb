class CreateCoreTimes < ActiveRecord::Migration
  def change
    create_table :core_times do |t|
      t.integer :theme_id
      t.datetime :start_at
      t.datetime :end_at
      t.boolean :notice

      t.timestamps
    end
  end
end
