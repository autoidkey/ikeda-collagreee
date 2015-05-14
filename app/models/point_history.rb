class PointHistory < ActiveRecord::Base
  belongs_to :entry, class_name: 'Entry'
  belongs_to :reply, class_name: 'Entry'
  belongs_to :theme
  belongs_to :user
  belongs_to :activity
  belongs_to :like
  belongs_to :notice

  enum atype: %i(active passive)
  enum action: %i(投稿 返信 Like 返信され Likeされ Likeを削除 Likeを削除され)

  scope :entry_point, ->(entry) { where(entry_id: entry, atype: 1) }
  scope :like_point, ->(like, version) { where(like_id: like, version_id: version) }
  scope :user_point, ->(user, atype, action, theme) { where(user_id: user, atype: atype, action: action, theme_id: theme) }
  scope :before0130, -> { where('created_at < ?', Time.zone.local(2015, 2, 3, 18, 00, 00)) }
  scope :after0130, -> { where('created_at >= ?', Time.zone.local(2015, 2, 3, 18, 00, 00)) }
  scope :point_history, ->(user, theme) { where(user_id: user, theme_id: theme).order('updated_at DESC') }

  # 今後これらを基礎ポイントとする
  ENTRY_POINT = 30.00
  REPLY_POINT = 20.00
  LIKE_POINT = 5.00
  REPLIED_POINT = 15.00
  LIKED_POINT = 5.00

  # 行動のポイントをセーブ(0.新規スレッド、1.返信、3.返信された)
  def self.save_active_point(entry, point, action)
    case action
    when 0
      Point.save_entry_point(entry.theme, point, entry.user)
    when 1
      Point.save_reply_point(entry.theme, point, entry.user)
    when 3
      Point.save_replied_point(entry.theme, point, entry.user)
    end
  end

  # POSTした時のポイント付与(0.新規スレッド、1.返信、3.返信された)
  def self.pointing_post(entry, atype, action)
    point = case action
            when 0
              ENTRY_POINT
            when 1
              REPLY_POINT
            when 3
              REPLIED_POINT
            end

    # 上のやつ
    PointHistory.save_active_point(entry, point, action)
    # Redisに何かやってる
    Point.save_theme_point(entry.theme, point, entry.user)

    params = {
      entry_id: entry.id,
      user_id: entry.user.id,
      theme_id: entry.theme.id,
      atype: atype,
      action: action,
      point: point
    }

    PointHistory.save_point(params)
  end

  # 返信された時のポイント付与
  def self.pointing_replied(entry, atype, action)
    point = REPLIED_POINT
    params = {
      entry_id: entry.parent.id,
      user_id: entry.parent.user.id,
      theme_id: entry.parent.theme.id,
      atype: atype,
      action: action,
      point: point,
      reply_id: entry.id
    }

    Point.save_replied_point(entry.theme, point, entry.parent.user)
    Point.save_theme_point(entry.theme, point, entry.parent.user)
    PointHistory.save_point(params)

    entry.parent.delay.scored(entry.parent.point)
  end

  #️ いいね！した時のポイント付与
  def self.pointing_like(like)
    params = {
      like_id: like.id,
      entry_id: like.entry.id,
      user_id: like.user.id,
      theme_id: like.theme.id,
      atype: 0,
      action: 2,
      point: LIKE_POINT,
      version_id: like.version_id
    }

    Point.save_like_point(like.theme, LIKE_POINT, like.user)
    Point.save_theme_point(like.theme, LIKE_POINT, like.user)
    PointHistory.save_point(params)
  end

  # いいね！された時のポイント付与
  def self.pointing_liked(like)
    entry = Entry.find(like.entry_id)
    depth = 0

    # ポイント伝搬
    loop {
      unless entry.mine?(like.user) && depth == 0 || entry.facilitation?
        params = {
          like_id: like.id,
          entry_id: entry.id,
          user_id: entry.user.id,
          theme_id: entry.theme.id,
          atype: 1,
          action: 4,
          depth: depth,
          point: LIKED_POINT / (2**depth),
          version_id: like.version_id
        }

        Point.save_liked_point(entry.theme, LIKED_POINT / (2**depth), entry.user)
        Point.save_theme_point(entry.theme, LIKED_POINT / (2**depth), entry.user)
        PointHistory.save_point(params)
        entry.delay.scored(entry.point)
      end

      depth += 1
      break if entry.is_root?
      entry = entry.parent
    }
  end

  # いいね！を取り消しした時のポイント削減
  def self.destroy_like_point(like)
    PointHistory.like_point(like, like.version_id).each do |history|
      destory_history = history.copy_attr_for_create
      destory_history.action = destory_history.atype ? 6 : 5 # 要チェック
      destory_history.point = -destory_history.point
      destory_history.version_id = like.version_id + 1
      destory_history.save
      Point.save_theme_point(destory_history.theme, destory_history.point, destory_history.user)

      if destory_history.active?
        Point.save_like_point(destory_history.theme, destory_history.point, destory_history.user)
      else
        Point.save_liked_point(destory_history.theme, destory_history.point, destory_history.user)
      end
      destory_history.entry.delay.scored(destory_history.entry.point)
    end
  end

  # ポイントをセーブ
  def self.save_point(params)
    point_history = PointHistory.new(params)
    point_history.save

    case point_history.action
    when '返信され'
      Notice.reply!(point_history)
    when 'Likeされ'
      Notice.like!(point_history) if point_history.depth == 0
    end
    PointHistory.delay.sending_notice(point_history)
  end

  # メールでお知らせ
  def self.sending_notice(point_history)
    if point_history.user.remind == 'お知らせメールを受け取る'
      if point_history.theme.point_function
        case point_history.action
        when '返信され'
          NoticeMailer.reply_notice(point_history).deliver
        when 'Likeされ'
          NoticeMailer.like_notice(point_history).deliver if point_history.depth == 0
        end
      else
        case point_history.action
        when '返信され'
          NoticeMailer.reply_notice_no_point(point_history).deliver
        when 'Likeされ'
          NoticeMailer.like_notice_no_point(point_history).deliver if point_history.depth == 0
        end
      end
    end
  end

  def self.logging_destory(like)
    params = {
      like_id: like.id,
      entry_id: like.entry.id,
      user_id: like.user.id,
      theme_id: like.theme.id,
      atype: 0,
      action: 5,
      point: 0
    }
    PointHistory.save_point(params)
  end

  def copy_attr_for_create
    PointHistory.new do |ph|
      CALL_FUNC.each do |func|
        ph.send("#{func}=", send(func))
      end
    end
  end

  CALL_FUNC = %w(like_id entry_id user_id theme_id atype action depth point)

  # def self.accessible_attributes
  #   ["like_id", "entry_id", "user_id", "theme_id", "atype", "action", "depth", "point"]
  # end
end
