require 'rails_helper'

describe Like, :type => :model do
  let(:user) { FactoryGirl.create(:user) }
  let(:other_user) { FactoryGirl.create(:user) }
  let(:entry) { FactoryGirl.create(:entry, user: user) }

  describe '投稿にLikeした時' do

    context '自分の投稿にLikeした時' do
      let(:like) { FactoryGirl.create(:like, user: user, entry: entry) }
      it 'Likeポイントは加算されない' do
        expect { like }.to change { PointHistory.count }.by(0)
      end
    end

    context '自分以外の投稿にLikeした時' do
      let(:like) { FactoryGirl.create(:like, user: other_user, entry: entry) }
      it 'Like&Likedポイントが加算される' do
        expect { like }.to change { PointHistory.count }.by(2)
      end
    end
  end

  describe '返信（親がいる投稿）にLikeした時' do
    let(:child1) {FactoryGirl.create(:entry, user: user, parent_id: entry.id) }
    let(:child2) {FactoryGirl.create(:entry, user: user, parent_id: child1.id) }

    context '自分の投稿にLikeした時' do
      let(:like) { FactoryGirl.create(:like, user: user, entry: child2) }
      it 'Likeポイントは加算されない' do
        expect { like }.to change { PointHistory.count }.by(0)
      end
    end

    context '自分以外の投稿にLikeした時' do
      let(:like) { FactoryGirl.create(:like, user: other_user, entry: child2) }
      it 'Like&Likedポイントが加算される' do
        expect { like }.to change { PointHistory.count }.by(4)
      end
    end
  end
end
