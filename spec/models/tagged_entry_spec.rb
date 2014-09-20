require 'rails_helper'

RSpec.describe TaggedEntry, :type => :model do
  let(:theme) { FactoryGirl.create(:theme) }
  let(:entry) { FactoryGirl.create(:entry, theme_id: theme.id) }
  let(:tag) { FactoryGirl.create(:issue, theme_id: theme.id) }
  let(:tag2) { FactoryGirl.create(:issue, theme_id: theme.id) }

  describe 'issuesとentryが多対多の関係をもつ' do
    before do
      entry.tagging!([tag, tag2])
      entry.save
    end

    it { expect(entry.issues).to match_array [tag, tag2] }
  end
end
