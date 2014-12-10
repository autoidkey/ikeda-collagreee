class AddHasReplyToEntry < ActiveRecord::Migration
  def change
    add_column :entries, :has_reply, :integer
  end
end
