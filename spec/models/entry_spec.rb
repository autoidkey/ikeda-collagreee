require 'rails_helper'

RSpec.describe Entry, :type => :model do
  let(:user) { FactoryGirl.create(:user) }
  let(:entry) { FactoryGirl.create(:entry, user: user) }

  describe 'もしリプライがあれば' do
    let(:user2) { FactoryGirl.create(:user) }
    let!(:child1) { FactoryGirl.create(:entry, parent_id: entry.id, user: user2) }
    let!(:child2) { FactoryGirl.create(:entry, parent_id: entry.id, user: user2) }

    it 'リプライからルートノードを取ることができる' do
      expect(child1.root_user).to eq user
    end

    it 'すべてのリプライを取得できる' do
      expect(entry.thread_entries).to match_array [child1, child2]
    end

    it 'リプライしたすべてのユーザも取得出来る' do
      expect(entry.thread_posted_user).to eq [user2]
    end
  end

  describe 'エントリーが作られた時' do
    before { entry }

    it 'Activityを作成する' do
      expect(Activity.all.count).to eq 1
    end
  end
end
