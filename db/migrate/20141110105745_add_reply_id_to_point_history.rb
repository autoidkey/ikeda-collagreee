class AddReplyIdToPointHistory < ActiveRecord::Migration
  def change
    add_column :point_histories, :reply_id, :integer
  end
end
