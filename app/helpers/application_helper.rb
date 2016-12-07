module ApplicationHelper
  def user_icon_path(user)
    # user.image? ? user.image_url(:user_thumb) : 'people_icon.png'
    user.image? ? user.image_url(:user_thumb) : gravatar_icon(user)
  end

  def user_admin?(user)
    user && user.admin?
  end

  def user_organizer?(user)
    user && user.organizer?
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
    email = user.present? ? user.email : 'guest'
    email_hash = Digest::MD5.hexdigest(email).downcase
    identicon = '?d=identicon&s=40'
    'http://gravatar.com/avatar/' + email_hash + identicon
  end

  def smartphone?
    ua = request.env['HTTP_USER_AGENT']
    (ua.include?('Mobile') || ua.include?('Android')) ? true : false
  end

  def sjis_safe(str)
    [
     ["301C", "FF5E"], # wave-dash
     ["2212", "FF0D"], # full-width minus
     ["00A2", "FFE0"], # cent as currency
     ["00A3", "FFE1"], # lb(pound) as currency
     ["00AC", "FFE2"], # not in boolean algebra
     ["2014", "2015"], # hyphen
     ["2016", "2225"], # double vertical lines
     ["2049", "0021"], # ?
     ["FE0E", "0021"], # ?
     ["203C", "0021"], # ?
    ].inject(str) do |s, (before, after)|
      s.gsub(
             before.to_i(16).chr('UTF-8'),
             after.to_i(16).chr('UTF-8'))
    end
  end

  #ここはこれでいいのでは？
  def childlen_count(id,entry)
    count = 0
    serchlist = []
    serchlist.push(id)

    while(serchlist.count != 0)
      serchid = serchlist.shift
      entry.each do |e|
        if e.parent_id == serchid
          count = count + 1
          serchlist.push(e.id)
        end
      end
    end
    return count
  end
end
