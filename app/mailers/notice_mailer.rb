class NoticeMailer < ActionMailer::Base
  add_template_helper(ApplicationHelper)
  default from: 'from@example.com'
  SERVER_URL = 'http://collagree.com'
  TO = 'nanigashi03@gmail.com'


  # オートファシリテーションが投稿されたら通知する（ファシリテーターから返信がありました）


  # 類似した意見が投稿されたら通知(only + subview)

  # 議論に参加してください通知(only)
  def facilitate_join_notice(title,mail_title, mail_body, theme_id, user)
    @mail_title = mail_title
    @mail_body = mail_body

    mail(to: user.email, subject: '[COLLAGREE] '+title) do |format|
      format.html { render 'template'  }
    end
  end


  def auto_notice(title,mail_title, mail_body, theme_id,user)
    @mail_title = mail_title
    @mail_body = mail_body
    @url = SERVER_URL + '/themes/' + theme_id

    mail(to: user.email, subject: '[COLLAGREE] '+title) do |format|
      format.html { render 'template'  }
    end
  end


  def facilitation_notice(facilitation, user)
    @entry = facilitation
    @to = user
    @url = SERVER_URL + '/themes/' + @entry.theme.id.to_s

    mail to: @to.email, subject: '[COLLAGREE] 参加テーマにファシリテータからの投稿がありました！'
  end

  def reply_notice(point_history)
    @entry = point_history.entry
    @reply = point_history.reply
    @point = point_history.point
    @from = @reply.user
    @to = @entry.user
    @url = SERVER_URL + '/themes/' + @entry.theme.id.to_s

    mail to: @to.email, subject: '[COLLAGREE] 返信ポイント獲得！'
  end

  def like_notice(point_history)
    @from = point_history.like.user
    @to = point_history.user
    @entry = point_history.entry
    @point = point_history.point
    @url = SERVER_URL + '/themes/' + @entry.theme.id.to_s

    mail to: @to.email, subject: '[COLLAGREE] いいねポイント獲得！'
  end

  def reply_notice_no_point(point_history)
    @entry = point_history.entry
    @reply = point_history.reply
    @point = point_history.point
    @from = @reply.user
    @to = @entry.user
    @url = SERVER_URL + '/themes/' + @entry.theme.id.to_s

    mail to: @to.email, subject: '[COLLAGREE] 返信されました！'
  end

  def like_notice_no_point(point_history)
    @from = point_history.like.user
    @to = point_history.user
    @entry = point_history.entry
    @point = point_history.point
    @url = SERVER_URL + '/themes/' + @entry.theme.id.to_s

    mail to: @to.email, subject: '[COLLAGREE] いいねされました！'
  end

  def core_time_notice(core_time,user)
    @to = user
    @core_time = core_time
    @url = SERVER_URL + '/themes/' + core_time.theme_id.to_s

    mail to: @to.email, subject: '[COLLAGREE] コアタイムのお知らせ!!'
  end


end
