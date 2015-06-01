class CreateFKeywords < ActiveRecord::Migration
  def change
    create_table :f_keywords do |t|
      t.string :word
      t.float :score

      t.timestamps
    end
  end
end
