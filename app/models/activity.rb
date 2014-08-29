class Activity < ActiveRecord::Base
  belongs_to :user
  belongs_to :entry
  belongs_to :theme

  default_scope -> { order('updated_at DESC') }

  scope :user,  ->(id) { where(user_id: id) }

  enum atype: %i(投稿しました。 返信しました。 返信されました。)

  def self.type(entry)
    entry.parent_id.nil? ? 0 : 1 # CONTENT
  end

  def self.logging(entry, type = nil)
    activity = Activity.new
    activity.theme_id = entry.theme_id
    activity.user_id = entry.user_id
    activity.entry_id = entry.id
    activity.atype = type || Activity.type(entry)
    activity.save
  end

  def in_theme?(theme_id)
    self.theme_id == theme_id
  end
end
