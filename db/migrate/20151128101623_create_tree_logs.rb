class CreateTreeLogs < ActiveRecord::Migration
  def change
    create_table :tree_logs do |t|
      t.integer :user_id
      t.integer :theme_id

      t.timestamps
    end
  end
end
