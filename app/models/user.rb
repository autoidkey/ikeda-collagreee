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

  ACTIVITY_COUNT = 10

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
