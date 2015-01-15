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

  private

  MOBILE_BROWSERS = ["android", "ipod", "opera mini", "blackberry", "palm","hiptop","avantgo","plucker", "xiino","blazer","elaine", "windows ce; ppc;", "windows ce; smartphone;","windows ce; iemobile", "up.browser","up.link","mmp","symbian","smartphone", "midp","wap","vodafone","o2","pocket","kindle", "mobile","pda","psp","treo"]

  def smartphone?
    agent = request.headers['HTTP_USER_AGENT'].downcase
    MOBILE_BROWSERS.each do |m|
      true if agent.match(m)
    end
    false
  end
end
