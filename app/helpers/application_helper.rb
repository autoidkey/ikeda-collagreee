module ApplicationHelper
  def user_icon_path(user)
    user.image? ? user.image.thumb : 'people_icon.png'
  end
end
