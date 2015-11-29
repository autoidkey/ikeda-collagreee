class AddBodyToYouyakuW < ActiveRecord::Migration
  def change
    add_column :youyaku_ws, :body, :string
  end
end
