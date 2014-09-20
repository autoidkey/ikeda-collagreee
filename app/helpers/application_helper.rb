module ApplicationHelper
  def user_icon_path(user)
    user.image? ? user.image.thumb : 'people_icon.png'
  end

  def user_admin?(user)
    user && user.admin?
  end
end
