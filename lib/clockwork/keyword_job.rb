# theme内のエントリーに出現する単語のtfidf
class KeywordJob
  include Bm25

  def execute
    Theme.all.each do |theme|
      entries = theme.visible_entries.select { |e| e.body.present? }
      theme.keywords.all.delete_all
      calculate(entries).each do |key, val|
        params = {
          word: key,
          score: val[:score],
          agree: val[:agree],
          disagree: val[:disagree],
          theme_id: theme.id
        }
        Keyword.new(params).save
      end
    end

  end
end
