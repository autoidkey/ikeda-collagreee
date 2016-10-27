class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.string :live
      t.string :city_name_1
      t.text :city_reason_1
      t.string :city_name_2
      t.text :city_reason_2
      t.string :city_name_3
      t.text :city_reason_3
      t.string :city_name_4
      t.text :city_reason_4
      t.string :city_name_5
      t.text :city_reason_5
      t.string :city_name_6
      t.text :city_reason_6
      t.text :q1
      t.text :q2
      t.string :q3_1
      t.text :q3_2

      t.timestamps
    end
  end
end
