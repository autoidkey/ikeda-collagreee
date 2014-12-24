class Point < ActiveRecord::Base
  belongs_to :user
  belongs_to :theme

  scope :user_point, ->(theme) { where(theme: theme, latest: true) }
  scope :user_all_point, ->(user, theme) { where(theme: theme, user: user) }
end
