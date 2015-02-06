class AddSumPointToPoint < ActiveRecord::Migration
  def change
    add_column :points, :sum, :integer
  end
end
