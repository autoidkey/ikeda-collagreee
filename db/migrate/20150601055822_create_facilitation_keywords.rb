class CreateFacilitationKeywords < ActiveRecord::Migration
  def change
    create_table :facilitation_keywords do |t|
      t.integer :theme_id
      t.string :word
      t.float :score

      t.timestamps
    end
  end
end
