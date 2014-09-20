require 'rails_helper'

describe IssuesController, :type => :controller do
  let(:user) { FactoryGirl.create(:user) }
  let(:facilitator) { FactoryGirl.create(:facilitator) }

  describe '#create' do
    let(:theme) { FactoryGirl.create(:theme) }
    let(:issue) { FactoryGirl.attributes_for(:issue, theme_id: theme.id) }

    context 'ユーザがsign_inしている時' do

      context 'ユーザがnormalユーザの時' do
        before { sign_in user }

        it 'トップページにリダイレクト' do
          post :create, issue: issue
          expect(response).to redirect_to(root_path)
        end

        it '新しいissueは作られない' do
          expect { post :create, issue: issue }.to change { Issue.count }.by(0)
        end
      end

      context 'ユーザがadminとfacilitatorの場合' do
        before { sign_in facilitator }

        it 'Theme#showにリダイレクト' do
          post :create, issue: issue
          expect(response).to redirect_to(theme)
        end

        it '新しいエントリが作成される' do
          expect { post :create, issue: issue }.to change { Issue.count }.by(1)
        end
      end
    end

    context 'ユーザがsign_inしていない時' do
      it 'ログインページにリダイレクト' do
        post :create, issue: issue
        expect(response).to redirect_to(new_user_session_path)
      end

      it '新しいissueは作られない' do
        expect { post :create, issue: issue }.to change { Issue.count }.by(0)
      end
    end
  end
end
