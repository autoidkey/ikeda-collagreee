module ApplicationHelper
  def user_icon_path(user)
    # user.image? ? user.image_url(:user_thumb) : 'people_icon.png'
    user.image? ? user.image_url(:user_thumb) : gravatar_icon(user)
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

  def gravatar_icon(user)
    if user_signed_in?
      email_hash = Digest::MD5.hexdigest(user.email).downcase
      identicon = '?d=identicon&s=40'
      'http://gravatar.com/avatar/' + email_hash + identicon
    end
  end

  def smartphone?
    ua = request.env['HTTP_USER_AGENT']
    (ua.include?('Mobile') || ua.include?('Android')) ? true : false
  end
end
