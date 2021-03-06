class User < ActiveRecord::Base
  mount_uploader :image, ImageUploader

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
  :recoverable, :rememberable, :trackable, :validatable, :timeoutable

  # validates :name, :realname, presence: true
  validates :name, presence: true

  has_many :entries
  has_many :activities
  has_many :keywords
  has_many :themes
  has_many :themes, through: :joins
  has_many :joins
  has_many :likes
  has_many :points
  has_many :point_histories
  has_many :notices
  has_many :webviews
  has_many :vote_entries

  enum role: %i(admin facilitator normal organizer)
  enum gender: %i(男性 女性)
  enum age: %i(10代未満 10代 20代 30代 40代 50代 60代 70代以上)
  enum home: %i(名古屋市内 愛知県内 愛知県外)
  enum move: %i(学生 会社員 公務員 主婦 自営業 その他)
  enum remind: %i(お知らせメールを受け取る お知らせメールを受け取らない)
  enum mail_format: %i(HTMLメール TEXTメール)

  ACTIVITY_COUNT = 5
  THEME_POINT = 'theme.point'
  USER_POINT = 'user.point'
  BEFORE_0130 = 'before_0130'
  AFTER_0130 = 'after_0130'
  EXPERIMENT_NAME = 'load_test'

  scope :theme_entries, ->(theme) { where(entry_id: entry, status: 1) }

  def entry_point(theme)
    points.user_point(theme).present? ? points.user_point(theme).last.entry : 0.0
  end

  def reply_point(theme)
    points.user_point(theme).present? ? points.user_point(theme).last.reply : 0.0
  end

  def like_point(theme)
    points.user_point(theme).present? ? points.user_point(theme).last.like : 0.0
  end

  def replied_point(theme)
    points.user_point(theme).present? ? points.user_point(theme).last.replied : 0.0
  end

  def liked_point(theme)
    points.user_point(theme).present? ? points.user_point(theme).last.liked : 0.0
  end

  def sum_point(theme)
    points.user_point(theme).present? ? points.user_point(theme).last.sum : 0.0
  end

  def point(theme)
    points.user_point(theme).present? ? points.user_point(theme).last : nil
  end

  def calculate_entry_point(theme)
    calculating_point(0, 0, theme)
  end

  def calculate_reply_point(theme)
    calculating_point(0, 1, theme)
  end

  def calculate_like_point(theme)
    calculating_point(0, 2, theme)  +  calculating_point(0, 6, theme)
  end

  def calculate_replied_point(theme)
    calculating_point(1, 3, theme)
  end

  def calculate_liked_point(theme)
    calculating_point(1, 4, theme) + calculating_point(1, 6, theme)
  end

  def destroy_like_point(theme)
    calculating_point(0, 6, theme)
  end

  def destroy_liked_point(theme)
    calculating_point(1, 6, theme)
  end

  def calculate_active_point(theme)
    calculate_entry_point(theme) + calculate_reply_point(theme) + calculate_like_point(theme)
  end

  def calculate_passive_point(theme)
    calculate_replied_point(theme) + calculate_liked_point(theme)
  end

  def calculate_sum_point(theme)
    calculate_active_point(theme) + calculate_passive_point(theme)
  end

  def point_history(theme)
    PointHistory.point_history(self, theme)
  end

  def calculating_point(atype, action, theme)
    PointHistory.user_point(self, atype, action, theme).inject(0){ |sum, history| sum + history.point }
  end

  def self.admin?(type)
    type == 0
  end

  def self.organizer?(type)
    type == 3
  end

  def update_user!(password, email, user_data)
    if password_changed?(password) || email_changed?(email)
      update_with_password(user_data)
    else
      update_without_password(user_data)
    end
  end

  def delete_notice(theme)
    Notice.old_notice(self, theme).delete_all
  end

  def read_reply_notice(theme)
    Notice.old_reply_notice(self, theme).each do |n|
      n.update(read: true)
    end
  end

  def read_like_notice(theme)
    Notice.old_like_notice(self, theme).each do |n|
      n.update(read: true)
    end
  end

  def having_point(theme)
    points.find_by(theme_id: theme, latest: true)
  end

  def password_changed?(password)
    !password.blank?            # blankだっけ？
  end

  def acitivities_in_theme(theme)
    activities.all.includes(:entry).select { |a| a.in_theme?(theme.id) }.take(ACTIVITY_COUNT)
  end

  def like!(entry)
    like = Like.find_by(entry_id: entry, user_id: self)
    if like.present?
      like.status = 1
      like.version_id += 1
      like.save
      Like.logging(like)
    else
      params = {
        entry_id: entry.id,
        user_id: self.id,
        theme_id: entry.theme_id,
        status: 1,
        version_id: 0,
      }
      like = Like.new(params)
      like.save
      Like.logging(like)
    end
  end

  def unlike!(entry)
    like = Like.find_by(entry_id: entry, user_id: self)
    Like.logging_destroy(like)
    like.version_id += 1
    like.status = 0
    like.save
  end

  # redis
  def score(theme)
    Redis.current.zscore([EXPERIMENT_NAME, THEME_POINT, theme.id.to_s, 'sum'].join(':'), id).to_i
  end

  def rank(theme)
    Redis.current.zrevrank([EXPERIMENT_NAME, THEME_POINT, theme.id.to_s, 'sum'].join(':'), id) + 1
  end

  def rank_point(theme)
    Redis.current.zscore([EXPERIMENT_NAME, THEME_POINT, theme.id.to_s, 'sum'].join(':'), id).to_i
  end

  # before_0130
  def score_before_0130(theme)
    Redis.current.zscore([EXPERIMENT_NAME, THEME_POINT, id.to_s, BEFORE_0130].join(':'), id).to_i
  end

  def rank_before_0130(theme)
    Redis.current.zrevrank([EXPERIMENT_NAME, THEME_POINT, id.to_s, BEFORE_0130].join(':'), id) + 1
  end

  def rank_point_before_0130(theme)
    Redis.current.zscore([EXPERIMENT_NAME, THEME_POINT, id.to_s, BEFORE_0130].join(':'), id).to_i
  end

  # after_0130
  def score_after_0130(theme)
    Redis.current.zscore([EXPERIMENT_NAME, THEME_POINT, id.to_s, AFTER_0130].join(':'), id).to_i
  end

  def rank_after_0130(theme)
    Redis.current.zrevrank([EXPERIMENT_NAME, THEME_POINT, id.to_s, AFTER_0130].join(':'), id) + 1
  end

  def rank_point_after_0130(theme)
    Redis.current.zscore([EXPERIMENT_NAME, THEME_POINT, id.to_s, AFTER_0130].join(':'), id).to_i
  end

  def redis_entry_point(theme)
    key = [EXPERIMENT_NAME, USER_POINT, id.to_s, theme.id.to_s, 'entry'].join(':')
    point = Redis.current.lrange(key, -1, -1)[0]
    point.present? ? point.to_f : 0.0
  end

  def redis_reply_point(theme)
    key = [EXPERIMENT_NAME, USER_POINT, id.to_s, theme.id.to_s, 'reply'].join(':')
    point = Redis.current.lrange(key, -1, -1)[0]
    point.present? ? point.to_f : 0.0
  end

  def redis_like_point(theme)
    key = [EXPERIMENT_NAME, USER_POINT, id.to_s, theme.id.to_s, 'like'].join(':')
    point = Redis.current.lrange(key, -1, -1)[0]
    point.present? ? point.to_f : 0.0
  end

  def redis_replied_point(theme)
    key = [EXPERIMENT_NAME, USER_POINT, id.to_s, theme.id.to_s, 'replied'].join(':')
    point = Redis.current.lrange(key, -1, -1)[0]
    point.present? ? point.to_f : 0.0
  end

  def redis_liked_point(theme)
    key = [EXPERIMENT_NAME, USER_POINT, id.to_s, theme.id.to_s, 'liked'].join(':')
    point = Redis.current.lrange(key, -1, -1)[0]
    point.present? ? point.to_f : 0.0
  end

  # @return [Boolean] user should be remembered when he logs in (with cookie)
  #   so he won't be asked to login again
  # デフォルトでDeviseのセッションを保存する
  def remember_me
    true
  end

  def update_without_current_password(params, *options)
    params.delete(:current_password)
 
    if params[:password].blank? && params[:password_confirmation].blank?
      params.delete(:password)
      params.delete(:password_confirmation)
    end
 
    result = update_attributes(params, *options)
    clean_up_passwords
    result
  end

  def theme_entries(theme)
    entries.in_theme(theme)
  end

  def entry_count
      entries.to_a.count
  end

  def like_count
      likes.to_a.count
  end

end
