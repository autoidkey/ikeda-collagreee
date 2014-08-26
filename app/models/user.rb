class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :entries
  has_many :activities

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

  def admin?
    role == 0
  end

  def password_changed?(password)
    !password.blank?            # blankだっけ？
  end

  # def email_changed?(email)
  #   self.email != email
  # end
end
