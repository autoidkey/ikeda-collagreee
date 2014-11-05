class RemoveUnlikeFromLikes < ActiveRecord::Migration
  def change
    remove_column :likes, :unlike, :integer
  end
end
