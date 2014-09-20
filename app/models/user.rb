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

  enum role: %i(admin facilitator normal)
  enum gender: %i(男性 女性)
  enum age: %i(10代未満 10代 20代 30代 40代 50代 60代 70代以上)
  enum home: %i(名古屋市在住 名古屋市以外在住)
  enum move: %i(名古屋市へ通勤・通学している 名古屋市へ通勤・通学していない)
  enum remind: %i(お知らせメールを受け取る お知らせメールを受け取らない)
  enum mail_format: %i(HTMLメール TEXTメール)

  ACTIVITY_COUNT = 5

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
