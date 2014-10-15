# natto wrapper
module Np
  class NattoWrapper
    NpNode = Regexp.new('^名詞|^動詞|^形容詞|^副詞').freeze
    Norm = Regexp.new('^名詞').freeze

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
end
