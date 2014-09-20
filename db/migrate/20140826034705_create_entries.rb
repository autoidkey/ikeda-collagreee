class CreateEntries < ActiveRecord::Migration
  def change
    create_table :entries do |t|
      t.string :title
      t.string :body
      t.integer :parent_id
      t.integer :np, default: 0
      t.integer :user_id
      t.boolean :facilitation, default: false
      t.boolean :invisible, default: false
      t.boolean :top_fix,  default: false

      t.timestamps
    end
  end
end
