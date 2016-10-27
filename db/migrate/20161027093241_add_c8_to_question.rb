class AddC8ToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :c8, :integer
  end
end
