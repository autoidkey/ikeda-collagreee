class Point < ActiveRecord::Base
  belongs_to :user
  belongs_to :theme

  scope :user_point, ->(theme) { where(theme: theme, latest: true) }
end
