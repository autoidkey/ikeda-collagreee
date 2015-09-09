class AddPhaseIdToPhase < ActiveRecord::Migration
  def change
    add_column :phases, :phase_id, :integer
  end
end
