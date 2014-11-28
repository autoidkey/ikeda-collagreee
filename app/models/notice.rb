class Notice < ActiveRecord::Base
  belongs_to :user
  belongs_to :point_history
  belongs_to :entry

  scope :new_notice, ->(user, theme) { where(user_id: user, read: false, theme_id: theme) }
  scope :old_notice, ->(user, theme) { where(user_id: user, theme_id: theme) }
end
