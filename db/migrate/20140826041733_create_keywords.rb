class CreateKeywords < ActiveRecord::Migration
  def change
    create_table :keywords do |t|
      t.string :word
      t.float :score
      t.integer :agree
      t.integer :disagree

      t.timestamps
    end
  end
end
