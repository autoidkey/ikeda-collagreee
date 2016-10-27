class AddC4ToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :c4, :integer
  end
end
