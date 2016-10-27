class AddC2ToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :c2, :integer
  end
end
