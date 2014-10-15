class DropTableNegoDicts < ActiveRecord::Migration
  def change
    drop_table :nego_dicts
  end
end
