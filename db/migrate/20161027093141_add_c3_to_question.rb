class AddC3ToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :c3, :integer
  end
end
