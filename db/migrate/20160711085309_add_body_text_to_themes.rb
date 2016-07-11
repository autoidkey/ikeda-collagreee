class AddBodyTextToThemes < ActiveRecord::Migration
  def change
    add_column :themes, :body_text, :text
  end
end
