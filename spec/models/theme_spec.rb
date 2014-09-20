require 'rails_helper'

RSpec.describe Theme, :type => :model do

  describe 'themeはusersと多対多の関係がある' do
    let(:theme1) { FactoryGirl.create(:theme) }
    let(:user1) { FactoryGirl.create(:user) }
    let(:user2) { FactoryGirl.create(:user) }
    let(:user3) { FactoryGirl.create(:user) }

    before do
      theme1.users << [user1, user2, user3]
      theme1.save
    end

    it { expect(theme1.users).to match_array [user1, user2, user3] }
  end
end
