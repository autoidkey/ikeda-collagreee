class AddC5ToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :c5, :integer
  end
end
