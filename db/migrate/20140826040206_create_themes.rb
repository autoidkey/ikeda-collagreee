class CreateThemes < ActiveRecord::Migration
  def change
    create_table :themes do |t|
      t.string :title
      t.string :body
      t.string :color
      t.boolean :facilitation, default: false
      t.boolean :nolink, default: false
      t.boolean :secret, defalut: false

      t.timestamps
    end
  end
end
