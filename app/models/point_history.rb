class PointHistory < ActiveRecord::Base
  belongs_to :entry
  belongs_to :theme
  belongs_to :user
  belongs_to :activity
  belongs_to :like

  enum atype: %i(active passive)
  enum action: %i(投稿 返信 Like 返信され Likeされ Likeを削除 Likeを削除され)

  scope :entry_point, ->(entry) { where( entry_id: entry, atype: 1 ) }
  scope :like_point, ->(like, version) { where( like_id: like, version_id: version ) }
  scope :user_point, ->(user, atype, action, theme) { where( user_id: user, atype: atype, action: action, theme_id: theme ) }
  scope :point_history, ->(user, theme) { where( user_id: user, theme_id: theme ).order('updated_at DESC') }

  ENTRY_POINT = 10.00
  REPLY_POINT = 10.00
  LIKE_POINT = 10.00
  REPLIED_POINT = 10.00
  LIKED_POINT = 10.00

  def self.pointing_post(entry, atype, action)
    point = case action
              when 0
              REPLY_POINT
              when 1
              ENTRY_POINT
              when 3
              REPLIED_POINT
            end
    params = {
      entry_id: entry.id,
      user_id: entry.user_id,
      theme_id: entry.theme_id,
      atype: atype,
      action: action,
      point: point
    }
    PointHistory.save_point(params)
  end

  def self.pointing_like(like)
    params = {
      like_id: like.id,
      entry_id: like.entry_id,
      user_id: like.user_id,
      theme_id: like.theme_id,
      atype: 0,
      action: 2,
      point: LIKE_POINT,
      version_id: like.version_id
    }
    PointHistory.save_point(params)
  end

  def self.pointing_liked(like)
    entry = Entry.find(like.entry_id)
    depth = 0

    loop {
      unless entry.mine?(like.user) && depth == 0
        params = {
          like_id: like.id,
          entry_id: entry.id,
          user_id: entry.user_id,
          theme_id: entry.theme_id,
          atype: 1,
          action: 4,
          depth: depth,
          point: LIKED_POINT/(2**depth),
          version_id: like.version_id
        }
        PointHistory.save_point(params)
      end

      depth += 1
      break if entry.is_root?
      entry = entry.parent
    }
  end

  def self.destroy_like_point(like)
    PointHistory.like_point(like, like.version_id).each do |history|
      destory_history = history.copy_attr_for_create
      destory_history.action = destory_history.atype ? 6 : 5
      destory_history.point = -destory_history.point
      destory_history.version_id = like.version_id + 1
      destory_history.save
    end
  end

  def self.save_point(params)
    point_history = PointHistory.new(params)
    point_history.save
  end

  def self.logging_destory(like)
    params = {
      like_id: like.id,
      entry_id: like.entry_id,
      user_id: like.user_id,
      theme_id: like.theme_id,
      atype: 0,
      action: 5,
      point: 0
    }
    PointHistory.save_point(params)
  end

  def copy_attr_for_create
    history = PointHistory.new
    PointHistory.accessible_attributes.each do |attr|
      history.send("#{attr}=", self.send("#{attr}")) if attr.length > 0
    end
    history
  end

  def self.accessible_attributes
    ["like_id", "entry_id", "user_id", "theme_id", "atype", "action", "depth", "point"]
  end
end
