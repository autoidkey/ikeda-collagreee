require 'rails_helper'

describe Entry, :type => :model do
  let(:user) { FactoryGirl.create(:user) }
  let(:entry) { FactoryGirl.create(:entry, user: user) }

  describe 'エントリーが作られた時' do
    it '投稿Activityが作成される' do
      expect { entry }.to change { Activity.count }.by(1)
    end
  end

  describe '親エントリーに対してリプライした時' do
    let(:child) { FactoryGirl.create(:entry, parent_id: entry.id, user: user) }
    before { entry }

    context '親エントリを自分が作った時' do
      it '投稿Activityが作成される' do
        expect { child }.to change { Activity.count }.by(1)
      end
    end

    context '自分以外の人が親エントリを作成していた時' do
      let(:other_user) { FactoryGirl.create(:user) }
      let(:other_entry) { FactoryGirl.create(:entry, user: other_user) }
      let(:child) { FactoryGirl.create(:entry, parent_id: other_entry.id, user: user) }

      before do
        entry
        other_entry
      end

      it '投稿ActivityとリプライActivityが作成される' do
        expect { child }.to change { Activity.count }.by(2)
      end
    end
  end

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
end
