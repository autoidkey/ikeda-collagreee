class RenameListUsersToEditability < ActiveRecord::Migration
  def change
  	rename_table :youyaku_ws, :youyakudata #この行を追加！
  end
end
