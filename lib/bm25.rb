module Bm25
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
      norms = norm_connection(text.body) # 連結単語取り出し
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
end
