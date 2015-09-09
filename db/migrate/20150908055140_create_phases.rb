class CreatePhases < ActiveRecord::Migration
  def change
    create_table :phases do |t|
      t.string :number

      t.timestamps
    end
  end
end
