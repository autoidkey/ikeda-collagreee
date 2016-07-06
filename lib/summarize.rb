module Summarize

  # public/stamps以下に存在する画像パスをArrayに
  def summary_ja(entry, entries, keywords, theme_id)
      s = ""
      parent_tex = change_text(search_id(entry["parent_id"],entries)["body"])
      midashi_tex = change_text(entry["body"])
      s = midashi_tex+" "+parent_tex+" "

      keywords.each do |keyword|
        s = s + change_text(keyword["word"])+" "
        s = s + keyword["score"].to_s + " "
      end
      IO.popen("python #{Rails.root}/python/midashi/comment_manager.py #{s}").each do |line|
        youyaku = Youyaku.new(body: line, target_id: entry["id"], theme_id: theme_id)
        youyaku.save
      end
  end

  def search_id(id , entry_all)
    entry_all.each do |entry|
      if entry["id"] == id
        return entry
      end
    end
    return nil
  end

  def change_text(tex)
    str = tex.gsub(/(\s)/,"")
    str = str.gsub(/《[^》]+》/, "")
    str = str.gsub(/　/, "  ")
    str = str.gsub('(', '（')
    str = str.gsub(')', '）')
    str = str.gsub('!', '！')
    str = str.gsub('&', '＆')
    str = str.gsub(/[\r\n]/,"")
    return str
  end

end
