class SearchEntry
  include ActiveModel::Model
  attr_accessor :issues, :order, :theme_id

  # def search_issues
  #   if order == 'time'
  #     Entry.in_theme(theme_id).sort_time.search_issues(issues)
  #   elsif order == 'popular'
  #     if issues.present?
  #       Entry.in_theme(theme_id).popular.select { |e| issues.map { |i| e.tagged_entries.map { |t| t.issue_id.to_s }.include?(i) }.include?(true) }
  #     else
  #       Entry.in_theme(theme_id).popular
  #     end
  #   end
  # end
end
