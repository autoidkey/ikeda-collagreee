require 'rails_helper'

describe ThemesController, :type => :controller do
  let(:theme) { FactoryGirl.create(:theme) }
  let(:user) { FactoryGirl.create(:user) }
  let(:facilitator) { FactoryGirl.create(:facilitator) }
  let(:admin) { FactoryGirl.create(:admin) }

  describe '#index' do
    it 'return http success' do
      get :index
      expect(response).to be_ok
    end

    context 'Themeが複数あれば' do
      let(:theme2) { FactoryGirl.create(:theme) }
      let(:entry) { FactoryGirl.create(:entry, theme_id: theme) }

      before do
        theme2
        Timecop.scale(3600)
        entry
      end

      it 'update_at順になる表示される（最新の投稿順）' do
        get :index
        expect(assigns[:themes]).to eq [theme, theme2]
      end
    end
  end

  describe '#show' do
    it 'return http success' do
      get :show, id: theme.id
      expect(response).to be_ok
    end

    context '投稿を複数のエントリを持っている時' do
      let(:entry) { FactoryGirl.create(:entry, theme_id: theme.id) }
      let(:entry2) { FactoryGirl.create(:entry, theme_id: theme.id) }
      let(:child_entry) { FactoryGirl.create(:entry, theme_id: theme.id, parent_id: entry2.id) }
      let(:other_theme) { FactoryGirl.create(:theme) }
      let!(:entry3) { FactoryGirl.create(:entry, theme_id: other_theme.id) }

      before do
        entry2
        Timecop.scale(3600)
        entry
        Timecop.scale(3600)
        child_entry
        get :show, id: theme.id
      end

      it '親投稿が更新時間順で表示される。また同じテーマの投稿のみ取得する' do
        expect(assigns[:entries]).to eq [entry2, entry]
      end
    end

    context '他にthemeがあるとき' do
      let(:theme0) { FactoryGirl.create(:theme) }
      let(:theme1) { FactoryGirl.create(:theme) }
      let(:theme2) { FactoryGirl.create(:theme) }
      let(:theme3) { FactoryGirl.create(:theme) }
      let(:theme4) { FactoryGirl.create(:theme) }
      let(:theme5) { FactoryGirl.create(:theme) }

      before do
        theme0
        Timecop.scale(3600)
        theme1
        Timecop.scale(3600)
        theme2
        Timecop.scale(3600)
        theme3
        Timecop.scale(3600)
        theme4
        Timecop.scale(3600)
        theme5
      end

      it '上位5つを出力する' do
        get :show, id: theme.id
        expect(assigns[:other_themes]).to eq [theme5, theme4, theme3, theme2, theme1]
      end
    end

    context 'ユーザがsign_inしてない時' do
      it '閲覧しているテーマのユーザ数は増えない' do
        expect { get :show, id: theme.id }.to change { theme.users.count }.by(0)
      end
    end

    context 'ユーザがsign_inしてる時' do
      context 'ユーザの属性がadminの時' do
        before { sign_in admin }
        it '閲覧しているテーマのユーザ数はが増える' do
          expect { get :show, id: theme.id }.to change { theme.users.count }.by(1)
        end
      end

      context 'ユーザの属性がfacilitatoroの時' do
        before { sign_in facilitator }
        it '閲覧しているテーマのユーザ数は増えない' do
          expect { get :show, id: theme.id }.to change { theme.users.count }.by(0)
        end
      end

      context 'ユーザの属性がnormalの時' do
        before { sign_in user }
        it '閲覧しているテーマのユーザ数はが増える' do
          expect { get :show, id: theme.id }.to change { theme.users.count }.by(1)
        end
      end
    end
  end

  describe '#new' do
    context 'ユーザがsign_inしていない時' do
      it 'ログインページにリダイレクト' do
        get :new
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'adminとしてログインしている時' do
      before { sign_in admin }

      it 'return http success' do
        get :new
        expect(response).to be_ok
      end
    end

    context 'admin以外でログインしている時' do
      before { sign_in user }

      it 'Theme#indexにリダイレクト' do
        get :new
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe '#create' do
    let(:theme) { FactoryGirl.attributes_for(:theme) }

    context 'ユーザがsign_inしていない時' do
      it '新しくテーマが作られない' do
        expect { get :create, theme: theme }.to change { Theme.count }.by(0)
      end

      it 'Theme#indexにリダイレクト' do
        get :create, theme: theme
        expect(response).to redirect_to(root_path)
      end
    end

    context 'adminとしてログインしている時' do
      before { sign_in admin }

      it '新しくテーマが作られる' do
        expect { get :create, theme: theme }.to change { Theme.count }.by(1)
      end
    end

    context 'admin以外でログインしている時' do
      before { sign_in user }

      it '新しくテーマが作られない' do
        expect { get :create, theme: theme }.to change { Theme.count }.by(0)
      end
      it 'Theme#indexにリダイレクト' do
        get :create, theme: theme
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
