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

  def entry_point
    calculating_point(0, 0)
  end

  def reply_point
    calculating_point(0, 1)
  end

  def like_point
    calculating_point(0, 2)
  end

  def replied_point
    calculating_point(1, 3)
  end

  def liked_point
    calculating_point(1, 4)
  end

  def calculating_point(atype, action)
    PointHistory.user_point(self, atype, action).inject(0){ |sum, history| sum + history.point }
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

  # def email_changed?(email)
  #   self.email != email
  # end
end
