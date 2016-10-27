class AddC1ToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :c1, :integer
  end
end
