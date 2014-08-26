class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.string :info
      t.string :atype
      t.string :read, default: false
      t.integer :user_id, null: false

      t.timestamps
    end
  end
end
