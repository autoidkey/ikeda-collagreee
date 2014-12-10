class AddHasPointToEntry < ActiveRecord::Migration
  def change
    add_column :entries, :has_point, :integer
  end
end
