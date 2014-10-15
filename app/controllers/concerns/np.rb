module Np
  NpNode = Regexp.new('^名詞|^動詞|^形容詞|^副詞').freeze
  Exculution = Regexp.new('[!-\/:-@\[-`{-~]').freeze
  Norm = Regexp.new('^名詞').freeze

  extend ActiveSupport::Concern
  included do
    def calculate(text)
      e = 0.000001
      np = 0
      hits = 0

      np_nodes(text).each do |node|
        n_result = NDict.where({word: node}).first
        p_result = PDict.where({word: node}).first

        n_occur = n_result.nil? ? 0 : n_result['count']
        p_occur = p_result.nil? ? 0 : p_result['count']

        next if n_occur + p_occur <= 0
        node_np = p_occur / (n_occur + p_occur + e)
        np += node_np
        hits += 1
      end
      hits > 0 ? (np / hits) * 100 : 50
    end
  end

  # npに必要なノード
  def np_nodes(text)
    parse_to_list(text).select { |e| NpNode.match(e.feature) }.map(&:surface)
  end

  # 名詞のみ
  def norm_nodes(text)
    parse_to_list(text).select { |e| Norm.match(e.feature) }.map(&:surface)
  end

  def parse_to_list(text)
    nm = Natto::MeCab.new
    ret = []
    nm.parse(text) do |e|
      ret << e
    end
    ret
  end
end
