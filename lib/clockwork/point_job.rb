class PointJob
  def execute
    User.all.each do |user|
      Point.where(user_id: user, latest: true).each { |p| p.update(latest: false) }
      user.joins.each do |join|
        theme = join.theme
        if theme.present?
          params = {
            theme_id: theme.id,
            user_id: user.id,
            entry: user.calculate_entry_point(theme),
            reply: user.calculate_reply_point(theme),
            like: user.calculate_like_point(theme),
            replied: user.calculate_replied_point(theme),
            liked: user.calculate_liked_point(theme),
            latest: true
          }
          point = Point.new(params)
          point.sum = point.entry + point.reply + point.like + point.replied + point.liked
          point.save
        end
      end
    end
  end
end
