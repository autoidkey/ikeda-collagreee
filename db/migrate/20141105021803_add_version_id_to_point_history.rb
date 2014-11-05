class AddVersionIdToPointHistory < ActiveRecord::Migration
  def change
    add_column :point_histories, :version_id, :integer
  end
end
