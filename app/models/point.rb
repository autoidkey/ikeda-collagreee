class Point < ActiveRecord::Base
  belongs_to :user
  belongs_to :theme

  scope :user_point, ->(user, theme) { find_by(user_id: user, theme: theme, latest: true) }
end
