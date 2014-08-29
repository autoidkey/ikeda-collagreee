require 'rails_helper'

RSpec.describe EntriesController, :type => :controller do
  let(:entry) { FactoryGirl.create(:entry) }
  let(:user) { FactoryGirl.create(:user) }

  describe '#create' do
    let(:theme) { FactoryGirl.create(:theme) }
    let(:entry) { FactoryGirl.attributes_for(:entry, theme_id: theme, user_id: user) }

    before do
      post :create, entry: entry
    end

    it { expect(Entry.all.count).to eq 1 }
  end
end
