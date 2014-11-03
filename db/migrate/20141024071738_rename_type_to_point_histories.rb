class RenameTypeToPointHistories < ActiveRecord::Migration
  def change
    rename_column :point_histories, :type, :atype
  end
end
