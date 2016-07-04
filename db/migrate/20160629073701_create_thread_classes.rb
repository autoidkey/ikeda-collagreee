class CreateThreadClasses < ActiveRecord::Migration
  def change
    create_table :thread_classes do |t|
      t.string :title
      t.string :parent_class

      t.timestamps
    end
  end
end
