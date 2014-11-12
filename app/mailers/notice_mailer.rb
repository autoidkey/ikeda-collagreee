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
  def reply_notice(point_history)
    @greeting = "Hi"
    @from = point_history.reply.user
    @to = point_history.entry.user
    @entry = point_history.entry
    @reply = point_history.reply

    mail to: @to.email
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notice_mailer.like_notice.subject
  #
  def like_notice(point_history)
    @greeting = "Hi"
    @from = point_history.like.user
    @to = point_history.user
    @entry = point_history.entry

    mail to: @to.email
  end
end
