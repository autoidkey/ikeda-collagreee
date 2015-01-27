class UserKeywordJob
  include Bm25

  def execute
    User.all.each do |user|
      user.keywords.delete_all

      user.joins.each do |join|
        next if user.joins.black?

        entries = join.theme.entries.where(user_id: user)
        replies = entries.map(&:parent)
        likes = Like.where(user_id: user, theme_id: join.theme.id).map(&:entry)
        text = entries + replies + likes

        calculate(text).each do |key, val|
          params = {
            word: key,
            score: val[:score],
            agree: val[:agree],
            disagree: val[:disagree],
            theme_id: join.theme.id,
            user_id: user.id
          }
          Keyword.new(params).save
        end
      end
    end
  end
end
