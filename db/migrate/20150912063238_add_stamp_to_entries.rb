class AddStampToEntries < ActiveRecord::Migration
  def change
    add_column :entries, :stamp, :string
  end
end
