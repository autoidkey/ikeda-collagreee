class CreateEntries < ActiveRecord::Migration
  def change
    create_table :entries do |t|
      t.string :title
      t.string :body
      t.integer :parent_id
      t.integer :np, defalut: 0
      t.integer :user_id
      t.boolean :facilitation, defalut: false
      t.boolean :invisible, defalut: false
      t.boolean :top_fix,  defalut: false

      t.timestamps
    end
  end
end
