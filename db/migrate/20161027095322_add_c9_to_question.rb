class AddC9ToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :c9, :integer
  end
end
