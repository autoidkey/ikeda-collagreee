class Notice < ActiveRecord::Base
  belongs_to :user
  belongs_to :point_history
  belongs_to :entry

  scope :new_notice, ->(user, theme) { where(user_id: user, read: false, theme_id: theme) }
  scope :old_notice, ->(user, theme) { where(user_id: user, theme_id: theme) }
  scope :old_reply_notice, ->(user, theme) { where(user_id: user, ntype: 1, theme_id: theme) }

  def self.reply!(point_history)
    params = {
      user_id: point_history.user.id,
      ntype: 1,
      read: false,
      theme_id: point_history.theme.id,
      point_history_id: point_history.id
    }
    notice = Notice.new(params)
    notice.save
  end
end
