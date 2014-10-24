class Like < ActiveRecord::Base
  belongs_to :entry
  belongs_to :user
  belongs_to :theme
  belongs_to :activity
  has_many :point_histories

  default_scope -> { order('updated_at DESC') }

  scope :liked_user, ->(user, entry) { where(entry_id: entry, user_id: user) }

  after_save :logging_like_point, :logging_liked_point

  def self.like!(entry, status, user)
    if status == "remove"
      like = Like.where(entry_id: entry.id, user_id: user)
      like.delete_all
    else
      like =  Like.new
      like.entry_id = entry.id
      like.user_id = entry.user_id
      like.theme_id = entry.theme_id
      like.save
    end
  end

  def logging_like_point
    PointHistory.pointing_like(self)
  end

  def logging_liked_point
    PointHistory.pointing_liked(self)
  end

  def self.remove_like!
  end

end
