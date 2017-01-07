class UsersController < ApplicationController
  # point_api
  include Bm25

  def index
    @entry = Entry.new

    if current_user.admin?
      @q = User.where.not(role: 0).ransack(params[:q])
      @users = @q.result
      @user = User.new
    elsif current_user.organizer?
      @q = User.where.not(role: [0, 3]).ransack(params[:q])
      @users = @q.result
      @user = User.new
    else
      render file: "#{Rails.root}/public/404.html"
    end

    @themes = Theme.all
    @core_times = CoreTime.all

    comment = FacilitationInfomation.where(:theme_id => params[:id]).last
    if comment != nil
      @f_comment = comment[:body]
    else
      @f_comment = "こんにちは。今回、議論のファシリテータを務めさせていただきます。よろしくお願いします！"
    end
    puts "ファシリテータからのコメントは = #{@f_comment}です！！"

    @users_all =User.all
  end

  def show
    @user = User.find(params[:id])
    @keyword = @user.keywords.group_by(&:theme_id)
    @entries = @user.entries
    @data = [
      [t('controllers.post'), @entries.root.count],
      [t('controllers.reply'), @entries.where.not(parent_id: nil).count],
      [t('controllers.approve'), @user.likes.status_on.count]
    ]
  end

  def user_mail
    theme = Theme.find(params[:theme_id])
    body = params[:body]
    theme.users.each do |user|
      NoticeMailer.notice_free(body, theme.id, user).deliver
    end

    redirect_to users_path
    
  end

  # idとroleの値の組を送る
  def update
    params[:users].each do |(id, value)|
      if value[:check] then
        User.find(id).update_attributes(:role => value[:role].to_i)
      end
    end
    redirect_to index
  end

  def bm25(entries)
    calculate(entries)
  end

  def delete_notice
    render nothing: true
    current_user.delete_notice(params[:theme_id])
  end

  def read_reply_notice
    render nothing: true
    current_user.read_reply_notice(params[:theme_id])
  end

  def read_like_notice
    render nothing: true
    current_user.read_like_notice(params[:theme_id])
  end


end
