class ChangeRoleToUSers < ActiveRecord::Migration
  def change
    change_column :users, :role, :integer,  defalut: 0
  end
end
