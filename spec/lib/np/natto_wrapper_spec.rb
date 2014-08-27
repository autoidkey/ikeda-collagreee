require 'rails_helper'

describe Np::NattoWrapper do

  include Np::NattoWrapper

  it 'hgoe' do
    expect(target_nodes('今日はいい天気ですよね')).to match_array %w(今日 いい 天気)
  end
end
