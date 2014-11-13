class NoticeMailer < ActionMailer::Base
  add_template_helper(ApplicationHelper)
  default from: 'from@example.com'

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notice_mailer.entry_notice.subject
  #
  def entry_notice
    @greeting = 'Hi'

    mail to: 'imi.yuma@itolab.nitech.ac.jp'
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notice_mailer.reply_notice.subject
  #
  def reply_notice(point_history)
    @entry = point_history.entry
    @reply = point_history.reply
    @point = point_history.point
    @from = @reply.user
    @to = @entry.user

    mail to: @to.email, subject: '[COLLAGREE] 返信ポイント獲得！'
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notice_mailer.like_notice.subject
  #
  def like_notice(point_history)
    @from = point_history.like.user
    @to = point_history.user
    @entry = point_history.entry
    @point = point_history.point

    mail to: @to.email, subject: '[COLLAGREE] Likeポイント獲得！'
  end
end
