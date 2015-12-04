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

    #スレッドのクラスタリングも実行
    idAll = Theme.all
    Entry.record_timestamps = false
    idAll.each do |id|
      themes_claster = test_func(id)
      themes_claster.each do |clas|
        entry = Entry.find(clas[:id])
        entry["claster"] = clas[:cla]
        entry.save
      end
    end
    Entry.record_timestamps = true

  end
end
