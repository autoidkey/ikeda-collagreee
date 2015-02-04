class Theme < ActiveRecord::Base
  has_many :entries, dependent: :destroy
  has_many :activities, dependent: :destroy # けす？
  has_many :issues, dependent: :destroy # けす？
  has_many :keywords, dependent: :destroy # けす？
  has_many :users, through: :joins
  has_many :joins
  has_many :likes
  has_many :points
  has_many :point_histories
  belongs_to :admin, class_name: 'User'

  mount_uploader :image, ImageUploader

  default_scope -> { order('updated_at DESC') }
  scope :others, ->(id) { where.not(id: id).limit(5) }

  THEME_POINT = 'theme.point:'
  BEFORE_0130 = ':before_0130'
  AFTER_0130 = ':after_0130'

  def sort_by_reply(issues)
    if issues.present?
      (entries.root.search_issues(issues).sort_by { |e| Entry.children(e.id).count }).reverse
    else
      (entries.root.sort_by { |e| Entry.children(e.id).count }).reverse
    end
  end

  def sort_by_new(issues)
    if issues.present?
      entries.root.sort_time.search_issues(issues)
    else
      entries.root.sort_time
    end
  end

  def sort_by_points(issues)
    if issues.present?
      entries.root.search_issues(issues).sort_by(&:point).reverse
    else
      entries.root.sort_by(&:point).reverse
    end
  end

  def join!(user)
    users << user
  end

  def join?(user)
    users.include?(user)
  end

  def visible_entries
    entries.where(invisible: false)
  end

  # Redis

  # def scored(score, user)
  #   Redis.current.zincrby(POINT_SUM + id.to_s, score, user.id)
  # end

  def score(user)
    Redis.current.zscore(THEME_POINT + id.to_s + ':sum', user.id).to_f
  end

  def point_ranking
    Redis.current.zrevrange(THEME_POINT + id.to_s + ':sum', 0, 19).map { |id| User.find(id) }
  end

  def score_before_0130(user)
    Redis.current.zscore(THEME_POINT + id.to_s + BEFORE_0130, user.id).to_f
  end

  def point_ranking_before_0130
    Redis.current.zrevrange(THEME_POINT + id.to_s + BEFORE_0130, 0, 10).map { |id| User.find(id) }
  end

  def score_after_0130(user)
    Redis.current.zscore(THEME_POINT + id.to_s + AFTER_0130, user.id).to_f
  end

  def point_ranking_after_0130
    Redis.current.zrevrange(THEME_POINT + id.to_s + AFTER_0130, 0, 10).map { |id| User.find(id) }
  end
end
