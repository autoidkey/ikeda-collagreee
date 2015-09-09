class RemoveNumberToPhase < ActiveRecord::Migration
  def change
    remove_column :phases, :number, :string
  end
end
