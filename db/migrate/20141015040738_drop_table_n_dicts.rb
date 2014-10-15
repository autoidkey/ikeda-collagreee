class DropTableNDicts < ActiveRecord::Migration
  def change
    drop_table :n_dicts
  end
end
