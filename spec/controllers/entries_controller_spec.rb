require 'rails_helper'

RSpec.describe EntriesController, :type => :controller do
  let(:entry) { FactoryGirl.create(:entry) }
  let(:user) { FactoryGirl.create(:user) }

  describe '#index' do
    it 'return http success' do
      get :index
      expect(response.status).to eq(200)
    end
  end

  describe '#new' do
    it 'return http success' do
      get :new
      expect(response.status).to eq(200)
    end
  end

  describe '#create' do
    let(:theme) { FactoryGirl.create(:theme) }
    let(:entry) { FactoryGirl.attributes_for(:entry, theme_id: theme, user_id: user) }

    before do
      post :create, entry: entry
    end

    it { expect(Entry.all.count).to eq 1 }
  end

  describe '#show' do
    it 'return http success' do
      get :show, id: entry.id
      expect(response.status).to eq(200)
    end

    context 'if has children' do
      let(:child_entry1) { FactoryGirl.create(:entry) }
      let(:child_entry2) { FactoryGirl.create(:entry) }

      before do
        child_entry1.update_attribute(:parent_id, entry.id)
        child_entry2.update_attribute(:parent_id, entry.id)
      end

      it 'display entry children' do
        get :show, id: entry.id
        expect(assigns[:entries]).to match_array [child_entry1, child_entry2]
      end
    end
  end
end
