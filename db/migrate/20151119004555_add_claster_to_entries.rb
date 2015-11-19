class AddClasterToEntries < ActiveRecord::Migration
  def change
    add_column :entries, :claster, :integer
  end
end
