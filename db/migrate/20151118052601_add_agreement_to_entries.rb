class AddAgreementToEntries < ActiveRecord::Migration
  def change
    add_column :entries, :agreement, :boolean
  end
end
