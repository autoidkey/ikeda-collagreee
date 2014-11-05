class AddUnlikeToLikes < ActiveRecord::Migration
  def change
    add_column :likes, :unlike, :int
  end
end
