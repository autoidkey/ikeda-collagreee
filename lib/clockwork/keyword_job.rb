# theme内のエントリーに出現する単語のtfidf
class KeywordJob
  include Tfidf
  include NattoWrapper

  def execute
    Theme.all.each do |theme|
      entries = theme.visible_entries.select { |e| e.body.present? }
      entry_count = entries.count # 総ドキュメント数
    end
  end
end
