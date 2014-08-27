require 'rails_helper'

RSpec.describe ThemesController, :type => :controller do
  let(:theme) { FactoryGirl.create(:theme) }

  describe '#index' do
    it 'return http success' do
      get :index
      expect(response.status).to eq(200)
    end
  end

  describe '#show' do
    it 'return http success' do
      get :show, id: theme.id
      expect(response.status).to eq(200)
    end

    context 'if has associated entries' do
      let(:entry) { FactoryGirl.create(:entry) }
      let!(:entry2) { FactoryGirl.create(:entry) }
      let!(:child_entry) { FactoryGirl.create(:entry, parent_id: entry2.id) }

      before do
        entry.update_attribute(:theme_id, theme.id)
        entry2.update_attribute(:theme_id, theme.id)
        child_entry.update_attribute(:theme_id, theme.id)
      end

      it 'display entries' do
        get :show, id: theme.id
        expect(assigns[:entries]).to match_array [entry, entry2]
      end
    end
  end

  describe '#new' do
    it 'return http success' do
      get :new
      expect(response.status).to eq(200)
    end
  end

  describe '#create' do
    let(:theme) { FactoryGirl.attributes_for(:theme) }
    before { get :create, theme: theme }

    it { expect(Theme.all.count).to eq 1 }
  end
end
