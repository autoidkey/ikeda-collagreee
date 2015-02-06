class CreatePoints < ActiveRecord::Migration
  def change
    create_table :points do |t|
      t.integer :theme_id
      t.integer :user_id
      t.boolean :latest
      t.integer :entry
      t.integer :reply
      t.integer :like
      t.integer :replied
      t.integer :liked

      t.timestamps
    end
  end
end
