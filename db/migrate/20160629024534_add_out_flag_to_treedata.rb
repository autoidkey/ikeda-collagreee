class AddOutFlagToTreedata < ActiveRecord::Migration
  def change
    add_column :treedata, :out_flag, :boolean
  end
end
