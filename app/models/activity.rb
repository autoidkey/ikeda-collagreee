class Activity < ActiveRecord::Base
  belongs_to :user
  belongs_to :entry
  belongs_to :theme

  # default_scope -> { order('created_at DESC') }

  scope :user,  ->(id) { where(user_id: id) }

  CONTENT = %w(投稿しました。 返信しました。).freeze

  def self.type(entry)
    entry.parent_id.nil? ? 0 : 1 # CONTENT
  end

  def self.logging(entry)
    activity = Activity.new
    activity.theme_id = entry.theme_id
    activity.user_id = entry.user_id
    activity.entry_id = entry.id
    activity.atype = Activity.type(entry)
    activity.save
  end
end
