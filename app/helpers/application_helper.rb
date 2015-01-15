module ApplicationHelper
  def user_icon_path(user)
    user.image? ? user.image_url(:user_thumb) : 'people_icon.png'
  end

  def user_admin?(user)
    user && user.admin?
  end

  def cut_off(text, length)
    if text.present?
      if text.length > length
        text.scan(/^.{#{length}}/m)[0] + "…"
      else
        text
      end
    else
      ''
    end
  end

  def smartphone?
    ua = request.env['HTTP_USER_AGENT']
    (ua.include?('Mobile') || ua.include?('Android')) ? true : false
  end
end
