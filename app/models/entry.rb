class Entry < ActiveRecord::Base
  belongs_to :user
  belongs_to :theme

  # default_scope -> { order('created_at DESC') }
  scope :in_theme, ->(theme) { where(theme_id: theme) }

  after_save :logging_activity

  def activity_type
    Activity.type(self)
  end

  def logging_activity
    activity = Activity.new
    activity.theme_id = theme_id
    activity.user_id = user_id
    activity.entry_id = id
    activity.atype = activity_type
    activity.save
  end
end
