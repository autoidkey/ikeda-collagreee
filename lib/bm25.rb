module Bm25

  require 'matrix'
  require 'complex'
  require 'rubygems'
  require 'k_means'

  NpNode = Regexp.new('^名詞|^動詞|^形容詞|^副詞').freeze
  Exculution = Regexp.new('[!-\/:-@\[-`{-~]').freeze
  Norm = Regexp.new('^名詞').freeze

  K = 2.0
  B = 0.75

  def calculate(entries)
    freq = {} # 単語出現回数
    df = {} # 単語出現文書数
    bm25 = {} # BM25値
    agree = {}
    disagree = {}

    all_words = %w()
    sum_words = 0.0
    n = entries.count.to_f # 全ドキュメント数

    entries.each do |text|

      if I18n.default_locale == :ja
        norms = norm_connection(text.body) # 連結単語取り出し（日本語）
      else
        p I18n.default_locale
        norms = get_nouns(text.body) # 英語版のときはこっち　(英語)
      end

      sum_words += all_word_count(text.body) # 全単語数
      # is_agree ||= text.np < 50 ? false : true

      freq_calc(norms, freq, text, agree, disagree)
      df_calc(norms, df, all_words)
    end

    avg_word_count = sum_words / n

    all_words.uniq.each do |node|
      bm25[node] = {
        score: idf(df[node], n) * (freq[node] * K + 1) / (freq[node] + K * (1 - B + B * (sum_words / avg_word_count))),
        agree: agree[node],
        disagree: disagree[node]
      }
    end

    bm25
  end

  def calculate2(entries)
    freq = {} # 単語出現回数
    df = {} # 単語出現文書数
    bm25 = {} # BM25値
    agree = {}
    disagree = {}

    all_words = %w()
    sum_words = 0.0
    n = entries.count.to_f # 全ドキュメント数

    entries.each do |text|
      norms = norm_connection2(text.body) # 連結単語取り出し
      sum_words += all_word_count(text.body) # 全単語数
      # is_agree ||= text.np < 50 ? false : true

      freq_calc(norms, freq, text, agree, disagree)
      df_calc(norms, df, all_words)
    end

    avg_word_count = sum_words / n

    all_words.uniq.each do |node|
      bm25[node] = {
        score: (idf(df[node], n)+1) * (freq[node] * K + 1) / (freq[node] + K * (1 - B + B * (sum_words / avg_word_count))) * 10,
        agree: agree[node],
        disagree: disagree[node]
      }
    end
    bm25
  end

  # entry = ["afdfa","fafa"]のような文章集合に対して
  def calculate3(entries)
    freq = {} # 単語出現回数
    df = {} # 単語出現文書数
    bm25 = {} # BM25値
    agree = {}
    disagree = {}

    all_words = %w()
    sum_words = 0.0
    n = entries.count.to_f # 全ドキュメント数

    entries.each do |text|
      norms = get_nouns(text) # 英語版のときはこっち
      sum_words += all_word_count(text) # 全単語数
      # is_agree ||= text.np < 50 ? false : true

      freq_calc2(norms, freq, text, agree, disagree)
      df_calc(norms, df, all_words)
    end

    avg_word_count = sum_words / n

    all_words.uniq.each do |node|
      bm25[node] = {
        score: (idf(df[node], n)+1) * (freq[node] * K + 1) / (freq[node] + K * (1 - B + B * (sum_words / avg_word_count))) * 10,
        agree: agree[node],
        disagree: disagree[node]
      }
    end
    bm25
  end

  def freq_calc(norms, freq, text, agree, disagree)
    norms.each do |node|
      freq[node] ||= 0
      freq[node] += 1
      agree[node] ||= 0
      disagree[node] ||= 0
     unless text.is_root?
        if text.np >= 50
          agree[node] += 1
        else
          disagree[node] += 1
        end
      end
    end
  end

  def freq_calc2(norms, freq, text, agree, disagree)
    norms.each do |node|
      freq[node] ||= 0
      freq[node] += 1
      agree[node] ||= 0
      disagree[node] ||= 0
    end
  end

  def df_calc(norms, idf, all_words)
    norms.uniq.each do |node|
      idf[node] ||= 0
      idf[node] += 1
      all_words << node
    end
  end

  def idf(df, n)
    Math::log10((n - df + 0.5) / df + 0.5) 
  end

  def all_word_count(text)
    parse_to_list(text).count
  end

  # npに必要なノード
  def np_nodes(text)
    parse_to_list(text).select { |e| NpNode.match(e.feature) }.map(&:surface)
  end

  # 名詞のみ
  def norm_nodes(text)
    parse_to_list(text).select { |e| Norm.match(e.feature) }.map(&:surface)
  end

  def two_norms_nodes(text)
    last = nil
    ret = []

    parse_to_list(text).each do |e|
      if last.present? && Norm.match(e.feature) && Norm.match(last.feature)
        ret << last.surface + e.surface if last.present?
      end
      last = e
    end
    ret
  end

  def norm_connection(text)
    count = 0
    norms = parse_to_list(text)
    ret = []

    norms.each_with_index do |e, idx|
      # その単語が名詞なら次の単語を見る
      if Norm.match(e.feature)
        count += 1
      # 名詞以外が出てきたら、それまでの名詞を全部結合して登録する
      else
        ret << norms[idx - count..idx -1].map(&:surface).join('') if count > 1
        count = 0
      end
    end
    ret
  end

  # だいたい上のやつと一緒だけど、こっちは複合単語じゃない単語についても抽出している
  def norm_connection2(text)
    count = 0
    norms = parse_to_list(text)
    ret = []

    norms.each_with_index do |e, idx|
      # その単語が名詞なら次の単語を見る
      if Norm.match(e.feature)
        count += 1
      # 名詞以外が出てきたら、それまでの名詞を全部結合して登録する
      else
        ret << norms[idx - count..idx -1].map(&:surface).join('') if count > 0
        count = 0
      end
    end
    ret
  end

  def parse_to_list(text)
    nm = Natto::MeCab.new
    ret = []
    nm.parse(text) do |e|
      ret << e if e.surface.present?
    end
    ret
  end

  #ここから影響の普及モデルの計算
  def new_idm
    count = 0
    for num1 in 0..@idm_result.length-1 do
      #頻度を探す fに入れておく！！
      f = 0
      for num2 in 0..@idm_F.length-1 do
        if @idm_result[num1][0] == @idm_F[num2][0]
          f = @idm_F[num2][1]
          break
        end
      end

      #期待値を計算する eに入れておく
      e = 0
      if f != 1
        e = 0.0
        for num in 2..f do
          e = e + (num-1)*((f.quo(@idm_n))*(@idm_link.quo(@idm_n-1)))**(num-1)
        end
      end

      #乖離度を計算する kとする
      k = 0.0

      k = ((@idm_result[num1][1] - e)**2).quo(e)

      @idm_K[count] = [@idm_result[num1][0],k.round(4),e]
      count = count + 1
    end

  end

  def idm
    entry_all = Entry.all.where(:theme_id => params[:id])
    word_array = []
    # { :name => "k-sato", :email => "k-sato@foo.xx.jp",:address => "Tokyo" }
    entry_all.each do |entry|
      if search_child(entry["id"] , entry_all).length != 0
        if entry["title"] != nil
          title = norm_connection2(entry["title"]).uniq
          body = norm_connection2(entry["body"]).uniq
          words = title + body
          com_idm([],entry["id"] ,entry_all)

          #リンク数を計算する
          
        # else
        #   body = norm_connection2(entry["body"]).uniq
        #   logger.info body
        end
      end
    end
    return nil
    
  end

  def com_idm(word_array, id , entry_all)
    @idm_n = @idm_n + 1
    entry = search_id(id, entry_all)
    words = norm_connection2(entry["body"]).uniq
    idm_f(words)
    children = search_child(id,entry_all) 

    word_array.each do |word|
      if words.include?(word) && word.length>1
        num = words.count(word)
        # ここで計算して結果の配列を成形する
        idm_result(word)
        words.push(word)
      end
    end
    
    if children.length != 0
      children.each do |child|
        @idm_link = @idm_link + 1
        com_idm(words,child , entry_all)
      end
    end
  end

  def idm_f(words)
    words.each do |word|
      flag = 0
      count = 0
      for f in @idm_F do
        if f[0] == word
          @idm_F[count][1] = @idm_F[count][1] + 1
          flag = 1
          break
        end
        count = count + 1
      end
      if flag == 0
        @idm_F.push([word,1])
      end
    end
  end

  def idm_result(word)
    #result配列に追加するwordがを登録されているか[["蠣久",2],["ピンク",4]]
    flag = 0
    count = 0
    for result in @idm_result do
      if result[0]==word
        @idm_result[count][1] = @idm_result[count][1] + 1
        flag = 1
        break
      end
      count = count + 1
    end
    if flag == 0
      @idm_result.push([word,1])
    end
  end



  def search_child(id, entry_all)
    child_id = []
    entry_all.each do |entry|
      if entry["parent_id"] == id
        child_id.push(entry["id"])
      end
    end
    return child_id
  end

  def search_parent(id, entry_all)
    entry_all.each do |entry|
      if entry["parent_id"] == id
        child_id.push(entry["id"])
      end
    end
    return child_id
  end

  def search_id(id , entry_all)
    entry_all.each do |entry|
      if entry["id"] == id
        return entry
      end
    end
    return nil
  end

  def parent_ids(entry_all)
    parent_id = []
    entry_all.each do |entry|
      if entry["parent_id"].nil?
        parent_id.push(entry["id"])
      end
    end
    return parent_id
  end

  #ここまで影響の普及モデルで使用する




  #英語のクラスタリング
  def clustering_en(id)
    path = "#{Rails.root}/python/clustering"

    entries = Entry.where(theme_id: id)
    # 親の投稿のidの一覧
    parent_ids = parent_ids(entries)
    # logger.info({t: parent_ids})
    # スレッドごとの記事のidが配列で入っている
    thread_array = serch_thread(entries , parent_ids)
    # logger.info({t: thread_array})
    if thread_array.length < 6
      return
    end

    # 最後にDBに保存できるように最後の文字とidを保存する
    thread_s = []
    # ファイルへの書き込み
    File.open("#{path}/file/input.txt", "w") do |file|
      thread_array.each do |threads|
        # sはスレッドを文字列をつなげ文字列
        s = ""
        threads.each do |entry_id|
          # スレッドの記事をつなげる
          s = s + change_text(Entry.find(entry_id).body)
        end
        thread_s.push(s)
        # ファイルに書き込む 
        file.puts s
      end
    end

    # あとからid読み出せるよう
    thread_ids = {}
    thread_s.each_with_index do |s,i|
      thread_ids[s[-3..-1]] = parent_ids[i]
    end


    IO.popen("python #{path}/clustering.py #{path}/file/input.txt #{path}/file/output.txt").each do |line|
      puts line
    end

    EntryClaster.destroy_all
    # pythonで書き込んだfileを読み出す
    File.open("#{path}/file/output.txt") do |file|
      file.each_line do |labmen|
        # idがthread_ids[labmen[-7..-2]]で\nが入るので-1してある
        entry = Entry.find(thread_ids[labmen[-4..-2]])

        cl = labmen[0, labmen.index(":")].to_i + 1
        # クラスの0はタイトルのために使うので0にはしない
        # entry.update(claster: cl)　昔の保存方式
        params = {
           entry_id: entry.id,
           coaster: cl,
        }
        EntryClaster.new(params).save
      end
    end

  end

  #ここまで


  def test_func(id)
    entry_all = Entry.all.where(:theme_id => id)

    #スレッドのタイトルのノードidを取得する
    parent_id = parent_ids(entry_all)
    if parent_id.length == 0
      return []
    end

    thread_array = serch_thread(entry_all , parent_id)
    bm25 = calculate2(entry_all)

    #スレッドごとの文章スレッド(thread_text_array)とスレッドの単語出現数thread_f_arrayとある単語がスレッドの文章にどれだけ出現するか（thread_n_array）文章を出す
    thread_text_array = []
    thread_f_array = []
    thread_n_array = []

    thread_array.each do |theme|
      thread_text = []
      n_array = []
      count = 0
      theme.each do |id|
        entry = search_id(id , entry_all)
        thread_text.push(entry.body)
        n = norm_connection2(entry.body)
        n_array.concat(n)
        count = count + n.length
        if !entry.title.nil? 
          thread_text.push(entry.title)
          n = norm_connection2(entry.title)
          n_array.concat(n)
          count = count + n.length
          n_array.concat(n)
          count = count + n.length
        end
      end
      thread_text_array.push(thread_text)
      thread_f_array.push(count)
      thread_n_array.push(n_array)
    end

    # logger.info thread_text_array
    # logger.info thread_f_array
    # logger.info thread_n_array

    thread_num = thread_n_array.length


    #それぞれのスレッドのtfidf値を出す。
    v_array = []
    for i in 0..thread_num-1 do
      v = []
      count = 0
      b = 0
      bm25.each{|key, value|
        num = 0
        thread_n_array[i].each do |n|
          if n == key
            num = num + 1
          end
        end
        if thread_f_array[i] == 0 
          v[count] = num
        else
          v[count] = (num.quo(thread_f_array[i]).to_f) * value[:score] * 3
        end
        count = count + 1
      }
      v_array[i] = v
    end

    for i in 0..thread_num-1 do
      # logger.info thread_text_array[i]
      # logger.info v_array[i]
    end

    #下の関数で作成
    kmeans = kmeans_func(v_array)

    #長さの合計値を計算
    ln = 0
    kmeans.each do |kmean|
      ln = ln + kmean.length
    end
    count = 0 

    while (ln/3) < kmeans[0].length do
      kmeans = kmeans_func(v_array)
      count = count + 1
      if count == 10
        break
      end
    end

    #jsに変換
    cla_array = []
    count = 1
    kmeans.each do |kmean|
      if kmean != nil
        kmean.each do |k|
          cla_array.push({ :cla => count, :id => parent_id[k]})
        end
      end
      count = count + 1
    end

    return cla_array

  end

  def  kmeans_func(v_array)
    #k-meansのクラス多数の設定！！
    if v_array.length / 3 == 0
      kmeans = KMeans.new(v_array, :centroids => 1)
    else
      kmeans = KMeans.new(v_array, :centroids => v_array.length / 3)
    end

    kmeans.inspect
    # logger.warn kmeans

    #jsで使うように加工
    kmeans = kmeans.view

    #クラスタがないのは消して、降順に並び替える
    temp = []
    for i in 0..kmeans.length-1 do
      temp.push(kmeans[i].length)
    end
    #それぞれの数
    # logger.warn "それぞれの数"
    # logger.warn temp

    #ここで並び替え実装!!
    for i in 0..kmeans.length-1 do
      for t in i+1..kmeans.length-1 do
        if kmeans[i].length < kmeans[t].length
          temp = kmeans
          temp[i],temp[t] = temp[t],temp[i]
          kmeans = temp
        end
      end
    end

    return kmeans;

  end


    def test_func2(id)
    entry_all = Entry.all.where(:theme_id => params[:id])

    #スレッドのタイトルのノードidを取得する
    parent_id = []
    entry_all.each do |entry|
      if entry["parent_id"].nil?
        parent_id.push(entry["id"])
      end
    end

    thread_array = serch_thread(entry_all , parent_id)

    bm25 = calculate2(entry_all)

    #スレッドごとの文章スレッド(thread_text_array)とスレッドの単語出現数thread_f_arrayとある単語がスレッドの文章にどれだけ出現するか（thread_n_array）文章を出す
    thread_text_array = []
    thread_f_array = []
    thread_n_array = []

    v_array = []

    thread_array.each do |theme|
      count = 0
      theme.each do |id|
        entry = search_id(id , entry_all)
        text_n = norm_connection2(entry.body)
        if !entry.title.nil? 
          text_n.concat(norm_connection2(entry.title))
        end
        f = text_n.length
        v = []
        count = 0
        bm25.each{|key, value|
          num = 0
          text_n.each do |n|
            if n == key
              num = num + 1
            end
          end

          v[count] = (num.quo(f).to_f) * value[:score]
          count = count + 1
        }
        v_array.push(v)
      end
    end

    # logger.info thread_text_array
    # logger.info thread_f_array
    # logger.info thread_n_array



    # for i in 0..thread_num-1 do
    #   # logger.info thread_text_array[i]
    #   # logger.info v_array[i]
    # end


    kmeans = KMeans.new(v_array, :centroids => 5)
    kmeans.inspect

    #jsで使うように加工
    cla_array = []
    kmeans = kmeans.view
    count = 0
    kmeans.each do |kmean|
      if kmean != nil
        kmean.each do |k|
          cla_array.push({ :cla => count, :id => parent_id[k]})
        end
      end
      count = count + 1
    end


    return cla_array

  end

  def serch_thread(entry_all , parent_array)
    array = []

    #再起によりスレッドのidをまとめ配列を生成する
    parent_array.each do |parent|
      temp = []
      temp.push(parent)
      imput_temp = child_thread(parent ,entry_all)
      if imput_temp != nil
        temp.concat(child_thread(parent ,entry_all))
      end
      array.push(temp)
    end
    return array
  end

  def child_thread(parent_id , entry_all)
    temp_array = []
    child_array = search_child(parent_id, entry_all)
    if child_array.length == 0
      return 
    else
      child_array.each do |child|
        temp_array.push(child)
        temp = child_thread(child , entry_all)
        if temp != nil
          temp_array.concat(temp)
        end
      end
    end
    return temp_array
  end


  # 不要な文字列を削除する themesのコントローラーで使われる
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


  def get_nouns(text)
    nouns = Array.new
    tokens = tokenize_english(text)
    tokens.each do |token|
      if token[1] == "NN"
        nouns.push(token[0])
      elsif token[1] == "NNS"
        nouns.push(token[2])
      end
    end
    return nouns
  end

  def tokenize_english(text)
    command = "echo \"#{text}\" | tteng"
    raw_text = `#{command}`
    words = raw_text.split("\n")
    results = Array.new
    words.each do |word|
      results.push(word.split("\t"))
    end
    return results
  end

end
