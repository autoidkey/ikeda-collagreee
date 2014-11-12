require "rails_helper"

RSpec.describe NoticeMailer, :type => :mailer do
  describe "entry_notice" do
    let(:mail) { NoticeMailer.entry_notice }

    it "renders the headers" do
      expect(mail.subject).to eq("Entry notice")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

  describe "reply_notice" do
    let(:mail) { NoticeMailer.reply_notice }

    it "renders the headers" do
      expect(mail.subject).to eq("Reply notice")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

  describe "like_notice" do
    let(:mail) { NoticeMailer.like_notice }

    it "renders the headers" do
      expect(mail.subject).to eq("Like notice")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

end
