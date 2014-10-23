require 'rails_helper'

describe EntriesController, :type => :controller do
  let(:user) { FactoryGirl.create(:user) }

  describe '#create' do
    let(:theme) { FactoryGirl.create(:theme) }
    let(:entry) { FactoryGirl.attributes_for(:entry, theme_id: theme.id, user_id: user.id) }

    context 'ユーザがsign_inしている時' do
      before { sign_in user }

      it 'Theme#showにリダイレクト' do
        post :create, :format => 'js', entry: entry
        expect(response).to be_success
      end

      it '新しいエントリが作成される' do
        expect { post :create, :format => 'js',  entry: entry }.to change { Entry.count }.by(1)
      end
    end

    context 'ユーザがsign_inしていない時' do
      it 'ログインページにリダイレクト' do
        post :create, entry: entry
        expect(response).to redirect_to(new_user_session_path)
      end

      it '新しいエントリは作られない' do
        expect { post :create, entry: entry }.to change { Entry.count }.by(0)
      end
    end
  end
end
