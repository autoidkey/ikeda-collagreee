require 'rails_helper'

describe NattoWrapper do
  include NattoWrapper

  it '#np_nodes名詞、動詞、形容詞、副詞を取る' do
    expect(np_nodes('笑顔が止まらない！踊るココロ止まらない！')).to match_array %w(ココロ 止まら 止まら 笑顔 踊る)
  end

  it '#norm_nodesは名詞のみを取る' do
    expect(norm_nodes('ワニとシャンプー')).to match_array %w(ワニ シャンプー)
  end
end
