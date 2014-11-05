class Like < ActiveRecord::Base
  belongs_to :entry
  belongs_to :user
  belongs_to :theme
  belongs_to :activity
  has_many :point_histories

  enum status: %i(unlike like)

  default_scope -> { order('updated_at DESC') }

  scope :liked_user, ->(user, entry) { where( user_id: user, entry_id: entry, status: 1 ) }
  scope :all_likes, ->(entry) { where( entry_id: entry, status: 1 ) }

  # after_save :logging_like_point, :logging_liked_point

  def self.like!(entry, status, user)
    if status == "remove"
      like = Like.find_by(entry_id: entry.id, user_id: user)
      Like.logging_destroy(like)
      like.version_id += 1
      like.status = 0
      like.save
    else
      like = Like.find_by(entry_id: entry.id, user_id: user)
      if like.present?
        like.status = 1
        like.version_id += 1
        like.save
        Like.logging(like)
      else
        params = {
          entry_id: entry.id,
          user_id: user.id,
          theme_id: entry.theme_id,
          status: 1,
          version_id: 0,
        }
        like = Like.new(params)
        like.save
        Like.logging(like)
      end
    end
  end

  def self.logging(like)
    logging_like_point(like)
    logging_liked_point(like)
  end

  def self.logging_destroy(like)
    PointHistory.destroy_like_point(like)
  end

  def self.logging_like_point(like)
    PointHistory.pointing_like(like) unless Entry.find(like.entry_id).mine?(like.user)
  end

  def self.logging_liked_point(like)
    PointHistory.pointing_liked(like)
  end

  def destroy_point
    PointHistory.destroy_like_point(self)
  end

  def self.remove_like!
  end

end
