module Bm25
  NpNode = Regexp.new('^名詞|^動詞|^形容詞|^副詞').freeze
  Exculution = Regexp.new('[!-\/:-@\[-`{-~]').freeze
  Norm = Regexp.new('^名詞').freeze

  # TEST_TEXTS = ['リンゴとレモンとレモン', 'リンゴとミカン']

  K = 2.0
  B = 0.75
  # N = TEST_TEXTS.count.to_f # 全ドキュメント数

  extend ActiveSupport::Concern
  included do

    def calculate(entries)
      freq = {} # 単語出現回数
      df = {} # 単語出現文書数
      bm25 = {} # BM25値
      all_words = %w()
      sum_words = 0.0
      n = entries.count.to_f # 全ドキュメント数

      entries.each do |text|
        norms = two_norms_nodes(text.body)
        sum_words += all_word_count(text.body)

        freq_calc(norms, freq)
        df_calc(norms, df, all_words)
      end

      avg_word_count = sum_words / n

      all_words.uniq.each do |node|
        bm25[node] = idf(df[node], n) * (freq[node] * K + 1) / (freq[node] + K * (1 - B + B * (sum_words / avg_word_count)))
      end
      bm25.sort_by { |key,val| -val }
    end

    def freq_calc(norms, freq)
      norms.each do |node|
        freq[node] ||= 0
        freq[node] += 1
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

    def parse_to_list(text)
      nm = Natto::MeCab.new
      ret = []
      nm.parse(text) do |e|
        # ret << e if e.surface.present? && e.surface.length > 1
        ret << e if e.surface.present?
      end
      ret
    end
  end
end
