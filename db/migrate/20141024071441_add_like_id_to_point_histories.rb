class AddLikeIdToPointHistories < ActiveRecord::Migration
  def change
    add_column :point_histories, :like_id, :integer
  end
end
