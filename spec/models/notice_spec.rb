require 'rails_helper'

describe Notice, type: :model do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:user2) { FactoryGirl.create(:user) }
  let!(:theme) { FactoryGirl.create(:theme) }
  let(:entry) { FactoryGirl.create(:entry, user: user, theme: theme) }
  let(:reply) { FactoryGirl.create(:entry, user: user, theme: theme, parent_id: entry.id) }
  let(:reply2) { FactoryGirl.create(:entry, user: user2, theme: theme, parent_id: entry.id) }
  let(:like) { FactoryGirl.create(:like, user: user, theme: theme, entry: reply) }
  let(:like2) { FactoryGirl.create(:like, user: user2, theme: theme, entry: reply) }
  let!(:point_history) { FactoryGirl.create(:point_history) }

  describe '#reply!' do
    context 'PointHistoryが渡される時' do
      it '返信されたユーザーへの通知が１件追加される' do
        expect { Notice.reply!(point_history) }.to change { Notice.count }.by(1)
      end
    end
  end

  describe '#like!' do
    context 'PointHistoryが渡される時' do
      it '賛同されたユーザーへの通知が１件追加される' do
        expect { Notice.like!(point_history) }.to change { Notice.count }.by(1)
      end
    end
  end

  describe 'ルート投稿が行われた' do
    it 'テーマに参加している全員に通知が追加される' do
      # expect { entry }.to change { Notice.count }.by(theme.joins.count)
    end
  end

  describe '返信が行われた' do

    context '返信先が自分ではない時' do
      it '返信先への通知が１件追加される' do
        expect { reply2 }.to change { Notice.count }.by(1)
      end
    end

    context '返信先が自分の時' do
      it '通知は追加されない' do
        expect { reply }.to change { Notice.count }.by(0)
      end
    end
  end

  describe '賛同が行われた' do
    it '賛同先へ１件通知が追加される' do
      # expect { like2 }.to change { Notice.count }.by(1)
    end
  end
end
