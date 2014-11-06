class User < ActiveRecord::Base
  mount_uploader :image, ImageUploader

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :entries
  has_many :activities
  has_many :themes
  has_many :themes, through: :joins
  has_many :joins
  has_many :likes
  has_many :point_histories

  enum role: %i(admin facilitator normal)
  enum gender: %i(男性 女性)
  enum age: %i(10代未満 10代 20代 30代 40代 50代 60代 70代以上)
  enum home: %i(名古屋市在住 名古屋市以外在住)
  enum move: %i(名古屋市へ通勤・通学している 名古屋市へ通勤・通学していない)
  enum remind: %i(お知らせメールを受け取る お知らせメールを受け取らない)
  enum mail_format: %i(HTMLメール TEXTメール)

  ACTIVITY_COUNT = 5

  def entry_point(theme)
    calculating_point(0, 0, theme)
  end

  def reply_point(theme)
    calculating_point(0, 1, theme)
  end

  def like_point(theme)
    calculating_point(0, 2, theme)  +  calculating_point(0, 6, theme)
  end

  def destroy_like_point(theme)
    calculating_point(0, 6, theme)
  end

  def replied_point(theme)
    calculating_point(1, 3, theme)
  end

  def liked_point(theme)
    calculating_point(1, 4, theme) + calculating_point(1, 6, theme)
  end

  def destroy_liked_point(theme)
    calculating_point(1, 6, theme)
  end

  def active_point(theme)
    entry_point(theme) + reply_point(theme) + like_point(theme)
  end

  def passive_point(theme)
    replied_point(theme) + liked_point(theme)
  end

  def sum_point(theme)
    active_point(theme) + passive_point(theme)
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

  def update_user!(password, email, user_data)
    if password_changed?(password) || email_changed?(email)
      update_with_password(user_data)
    else
      update_without_password(user_data)
    end
  end

  def password_changed?(password)
    !password.blank?            # blankだっけ？
  end

  def acitivities_in_theme(theme)
    activities.select { |a| a.in_theme?(theme.id) }.take(ACTIVITY_COUNT)
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

  # def email_changed?(email)
  #   self.email != email
  # end
end
