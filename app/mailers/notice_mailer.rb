class NoticeMailer < ActionMailer::Base
  add_template_helper(ApplicationHelper)
  default from: 'from@example.com'
  SERVER_URL = 'http://collagree.com'
  TO = 'nanigashi03@gmail.com'


  # オートファシリテーションが投稿されたら通知する（ファシリテーターから返信がありました）


  # 類似した意見が投稿されたら通知(only + subview)

  # 議論に参加してください通知(only)
  def facilitate_join_notice()

    
    mail(to: TO, subject: '[COLLAGREE] テストメール') do |format|
      format.html { render 'template'  }
    end
  end

  def facilitation_notice(facilitation, user)
    @entry = facilitation
    @to = user
    @url = SERVER_URL + '/themes/' + @entry.theme.id.to_s

    mail to: TO, subject: '[COLLAGREE] 参加テーマにファシリテータからの投稿がありました！'
  end

  def reply_notice(point_history)
    @entry = point_history.entry
    @reply = point_history.reply
    @point = point_history.point
    @from = @reply.user
    @to = @entry.user
    @url = SERVER_URL + '/themes/' + @entry.theme.id.to_s

    mail to: TO, subject: '[COLLAGREE] 返信ポイント獲得！'
  end

  def like_notice(point_history)
    @from = point_history.like.user
    @to = point_history.user
    @entry = point_history.entry
    @point = point_history.point
    @url = SERVER_URL + '/themes/' + @entry.theme.id.to_s

    mail to: TO, subject: '[COLLAGREE] いいねポイント獲得！'
  end

  def reply_notice_no_point(point_history)
    @entry = point_history.entry
    @reply = point_history.reply
    @point = point_history.point
    @from = @reply.user
    @to = @entry.user
    @url = SERVER_URL + '/themes/' + @entry.theme.id.to_s

    mail to: TO, subject: '[COLLAGREE] 返信されました！'
  end

  def like_notice_no_point(point_history)
    @from = point_history.like.user
    @to = point_history.user
    @entry = point_history.entry
    @point = point_history.point
    @url = SERVER_URL + '/themes/' + @entry.theme.id.to_s

    mail to: TO, subject: '[COLLAGREE] いいねされました！'
  end
end
