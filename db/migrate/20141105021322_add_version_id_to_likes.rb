class AddVersionIdToLikes < ActiveRecord::Migration
  def change
    add_column :likes, :version_id, :integer
  end
end
