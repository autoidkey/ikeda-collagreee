class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.string :content , :default => ''
      t.integer :np, :default =>  0
      t.boolean :root_node, :default => false
      t.string :form, :default =>  ''
      t.boolean :facilitation, :default =>  false

      t.timestamps
    end
  end
end
