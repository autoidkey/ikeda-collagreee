class CreateExclusions < ActiveRecord::Migration
  def change
    create_table :exclusions do |t|
      t.string :word
      t.timestamps
    end
  end
end
