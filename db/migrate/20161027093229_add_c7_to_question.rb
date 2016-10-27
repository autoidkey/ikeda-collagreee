class AddC7ToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :c7, :integer
  end
end
