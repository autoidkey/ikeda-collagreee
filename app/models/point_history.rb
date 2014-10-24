class PointHistory < ActiveRecord::Base
  belongs_to :entries
  belongs_to :themes
  belongs_to :users
  belongs_to :activities

  enum type: %i(active passive)
  enum action: %i(entry reply like replied liked)

  scope :entry_point, ->(entry) { where(entry_id: entry) }

  ENTRY_POINT = 10
  REPLY_POINT = 10
  LIKE_POINT = 10
  REPLIED_POINT = 10
  LIKED_POINT = 10

  def self.pointing_like(like)
    params = {
      like_id: like.id,
      entry_id: like.entry_id,
      user_id: like.user_id,
      theme_id: like.theme_id,
      atype: 0,
      action: 2,
      point: LIKE_POINT
    }
    PointHistory.save_point(params)
  end

  def self.pointing_liked(like)
    entry = Entry.find(like.entry_id)
    depth = 0

    loop {
      params = {
        like_id: like.id,
        entry_id: entry.id,
        user_id: entry.user_id,
        theme_id: entry.theme_id,
        atype: 1,
        action: 4,
        depth: depth,
        point: LIKED_POINT/(2**depth)
      }
      PointHistory.save_point(params)
      depth += 1
      break if entry.is_root?
      entry = entry.parent
    }
  end

  def self.save_point(params)
    point_history = PointHistory.new(params)
    point_history.save
  end

end
