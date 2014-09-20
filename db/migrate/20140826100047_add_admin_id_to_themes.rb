class AddAdminIdToThemes < ActiveRecord::Migration
  def change
    add_column :themes, :admin_id, :integer
  end
end
