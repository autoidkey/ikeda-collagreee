class AddC6ToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :c6, :integer
  end
end
