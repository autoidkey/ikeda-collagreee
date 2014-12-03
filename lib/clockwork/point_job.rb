class PointJob
  def execute
    User.all.each do |user|
      Point.where(user_id: user, latest: true).each { |p| p.update(latest: false) }
      user.joins.each do |join|
        theme = join.theme
        params = {
          theme_id: theme.id,
          user_id: user.id,
          entry: user.entry_point(theme),
          reply: user.reply_point(theme),
          like: user.like_point(theme),
          replied: user.replied_point(theme),
          liked: user.liked_point(theme),
          latest: true
        }
        Point.new(params).save
      end
    end
  end
end
