class Point < ActiveRecord::Base
  belongs_to :user
  belongs_to :theme

  default_scope -> { order('updated_at DESC') }

  THEME_POINT = 'theme.point'
  USER_POINT = 'user.point'
  BEFORE_0130 = 'before_0130'
  AFTER_0130 = 'after_0130'
  EXPERIMENT_NAME = 'load_test'

  def self.save_theme_point_before_0130(theme, score, user)
    Redis.current.zadd([EXPERIMENT_NAME, THEME_POINT, id.to_s, AFTER_0130].join(':'), score, user.id)
  end

  def self.save_theme_point_after_0130(theme, score, user)
    Redis.current.zadd([EXPERIMENT_NAME, THEME_POINT, id.to_s, AFTER_0130].join(':'), score, user.id)
  end

  def self.save_theme_point(theme, score, user)
    Redis.current.zincrby([EXPERIMENT_NAME, THEME_POINT, theme.id.to_s, 'sum'].join(':'), score, user.id)
  end

  def self.save_entry_point(theme, score, user)
    key = [EXPERIMENT_NAME, USER_POINT, user.id.to_s, theme.id.to_s, 'entry'].join(':')
    score += user.redis_entry_point(theme)
    Redis.current.rpush(key, score)
  end

  def self.save_reply_point(theme, score, user)
    key = [EXPERIMENT_NAME, USER_POINT, user.id.to_s, theme.id.to_s, 'reply'].join(':')
    score += user.redis_reply_point(theme)
    Redis.current.rpush(key, score)
  end

  def self.save_like_point(theme, score, user)
    key = [EXPERIMENT_NAME, USER_POINT, user.id.to_s, theme.id.to_s, 'like'].join(':')
    score += user.redis_like_point(theme)
    Redis.current.rpush(key, score)
  end

  def self.save_replied_point(theme, score, user)
    key = [EXPERIMENT_NAME, USER_POINT, user.id.to_s, theme.id.to_s, 'replied'].join(':')
    score += user.redis_replied_point(theme)
    Redis.current.rpush(key, score)
  end

  def self.save_liked_point(theme, score, user)
    key = [EXPERIMENT_NAME, USER_POINT, user.id.to_s, theme.id.to_s, 'liked'].join(':')
    score += user.redis_liked_point(theme)
    Redis.current.rpush(key, score)
  end
end
