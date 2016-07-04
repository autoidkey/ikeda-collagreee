class AddClasterIdToThreadClasses < ActiveRecord::Migration
  def change
    add_column :thread_classes, :claster_id, :integer
  end
end
