class Entry < ActiveRecord::Base
  belongs_to :user
  belongs_to :theme

  default_scope -> { order('created_at DESC') }
  scope :in_theme, ->(theme) { where(theme_id: theme) }
end
