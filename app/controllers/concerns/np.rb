module Np
  NpNode = Regexp.new('^名詞|^動詞|^形容詞|^副詞').freeze
  Exculution = Regexp.new('[!-\/:-@\[-`{-~]').freeze
  Norm = Regexp.new('^名詞').freeze

  extend ActiveSupport::Concern
  included do
    def calculate(text)
      p NDict.all
      p PDict.all
      np_nodes(text)
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

  def natto_test
    p "natto!"
  end
end
