class CreateNotices < ActiveRecord::Migration
  def change
    create_table :notices do |t|
      t.integer :ntype
      t.integer :user_id
      t.boolean :read
      t.integer :point_history_id

      t.timestamps
    end
  end
end
