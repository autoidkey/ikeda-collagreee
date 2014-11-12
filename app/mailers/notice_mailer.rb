class NoticeMailer < ActionMailer::Base
  default from: "from@example.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notice_mailer.entry_notice.subject
  #
  def entry_notice
    @greeting = "Hi"

    mail to: "imi.yuma@itolab.nitech.ac.jp"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notice_mailer.reply_notice.subject
  #
  def reply_notice
    @greeting = "Hi"

    mail to: "imi.yuma@itolab.nitech.ac.jp"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notice_mailer.like_notice.subject
  #
  def like_notice
    @greeting = "Hi"

    mail to: "imi.yuma@itolab.nitech.ac.jp"
  end
end
