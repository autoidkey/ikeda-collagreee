require 'rails_helper'

describe PointHistory, type: :model do
  let(:user) { FactoryGirl.create(:user) }
  let(:user2) { FactoryGirl.create(:user) }
  let(:theme) { FactoryGirl.create(:theme) }
  let!(:entry) { FactoryGirl.create(:entry, user: user, theme: theme) }
  let!(:reply) { FactoryGirl.create(:entry, user: user2, theme: theme, parent_id: entry.id) }
  let!(:like) { FactoryGirl.create(:like, user: user, theme: theme, entry: reply) }
  let!(:like2) { FactoryGirl.create(:like, user: user2, theme: theme, entry: reply) }

  describe '#pointing_post' do
    context '投稿する時' do
      it '投稿ポイントが加算される' do
        expect { PointHistory.pointing_post(entry, 0, 0) }.to change { PointHistory.count }.by(1)
      end
    end

    context '返信する時' do
      it '返信ポイントが加算される' do
        expect { PointHistory.pointing_post(entry, 1, 0) }.to change { PointHistory.count }.by(1)
      end
    end
  end

  describe '#pointing_like' do
    it 'likeポイントが加算される' do
      expect { PointHistory.pointing_like(like) }.to change { PointHistory.count }.by(1)
    end
  end

  describe '#pointing_liked' do
    context 'LikeするユーザーとLikeされる投稿のユーザーが異なる時' do
      it 'Likeされる投稿を含むルートまでの投稿にLikeポイントが加算される' do
        expect { PointHistory.pointing_liked(like) }.to change { PointHistory.count }.by(2)
      end

      it 'Likeされた人にメールが送られる' do
        expect { PointHistory.pointing_liked(like) }.to change { ActionMailer::Base.deliveries.count }.by(2)
      end
    end

    context 'LikeするユーザーとLikeされる投稿ユーザーが同じ時' do
      it 'Likeされる投稿以外の投稿にLikeポイントが加算される' do
        expect { PointHistory.pointing_liked(like2) }.to change { PointHistory.count }.by(1)
      end
    end
  end
end
