class AddKeywordToThemeId < ActiveRecord::Migration
  def change
    add_column :keywords, :theme_id, :integer
  end
end
