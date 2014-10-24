require 'rails_helper'

describe Like, :type => :model do
  let(:user) { FactoryGirl.create(:user) }
  let(:entry) { FactoryGirl.create(:entry, user: user) }

  describe '投稿にLikeした時' do
    let(:like) { FactoryGirl.create(:like, user: user, entry: entry) }
    it 'PointHistoryにより、Likeポイントが加算される' do
      expect { like }.to change { PointHistory.count }.by(2)
    end
  end

  describe '返信（親がいる投稿）にLikeした時' do
    let(:child1) {FactoryGirl.create(:entry, user: user, parent_id: entry.id) }
    let(:child2) {FactoryGirl.create(:entry, user: user, parent_id: child1.id) }
    let(:like) { FactoryGirl.create(:like, user: user, entry: child2) }

    it 'PointHistoryにより、ルート投稿まで（4つ）LikeとLikedポイントが加算される' do
      expect { like }.to change { PointHistory.count }.by(4)
    end
  end
end
