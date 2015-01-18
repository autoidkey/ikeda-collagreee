class Like < ActiveRecord::Base
  belongs_to :entry
  belongs_to :user
  belongs_to :theme
  belongs_to :activity
  has_many :point_histories

  enum status: %i(unlike like)

  default_scope -> { order('updated_at DESC') }

  scope :liked_user, ->(user, entry) { where(user_id: user, entry_id: entry, status: 1) }
  scope :all_likes, ->(entry) { where(entry_id: entry, status: 1) }

  # after_save :logging_like_point, :logging_liked_point

  def self.logging(like)
    logging_like_point(like)
    logging_liked_point(like)
  end

  def self.logging_destroy(like)
    PointHistory.destroy_like_point(like) unless like.
  end

  def self.logging_like_point(like)
    PointHistory.pointing_like(like) unless Entry.find(like.entry_id).mine?(like.user)
  end

  def self.logging_liked_point(like)
    PointHistory.pointing_liked(like)
  end
end
