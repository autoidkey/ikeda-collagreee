class AichiDlJob
  def execute
    User.all.each do |user|
      user.joins.each do |join|
        theme = join.theme
        if theme.present?
          point_history = user.point_history(theme)
          before_score = point_history.before0130.inject(0) { |sum, i| sum + i.point }
          after_score = point_history.after0130.inject(0) { |sum, i| sum + i.point }

          Point.save_theme_point_before_0130(theme, before_score, user)
          Point.save_theme_point_after_0130(theme, after_score, user)
        end
      end
    end
  end
end
