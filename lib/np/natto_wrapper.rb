module Np
  # natto wrapper
  module NattoWrapper
    Target = Regexp.new('^名詞|^動詞|^形容詞|^副詞').freeze

    def target_nodes(text)
      nm = Natto::MeCab.new
      ret = []
      nm.parse(text) do |e|
        ret << e.surface if Target.match(e.feature)
      end
      ret
    end
  end
end
